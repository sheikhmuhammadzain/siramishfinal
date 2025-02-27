from django.shortcuts import render, get_object_or_404
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from django.contrib.auth.models import User
from .models import Product, CartItem, Order, OrderItem
from django.db.models import Count, Sum
from django.utils import timezone
from datetime import timedelta
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import (
    UserSerializer, 
    ProductSerializer, 
    CartItemSerializer,
    OrderSerializer,
    OrderItemSerializer,
    CustomTokenObtainPairSerializer
)

# Create your views here.

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

    def post(self, request, *args, **kwargs):
        # Check if this is admin login
        username = request.data.get('username')
        if username == 'admin':
            try:
                user = User.objects.get(username=username)
                if not user.is_staff:
                    user.is_staff = True
                    user.is_superuser = True
                    user.save()
            except User.DoesNotExist:
                pass
        return super().post(request, *args, **kwargs)

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = UserSerializer

    def create(self, request, *args, **kwargs):
        # Extract username from email if not provided
        if 'username' not in request.data and 'email' in request.data:
            request.data['username'] = request.data['email'].split('@')[0]

        # Check if this is admin registration
        is_admin = request.data.get('email') == 'admin@email.com'
            
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            if is_admin:
                user.is_staff = True
                user.is_superuser = True
                user.save()
                
            # Include is_staff in response
            data = serializer.data
            data['is_staff'] = user.is_staff
            
            headers = self.get_success_headers(serializer.data)
            return Response(data, status=status.HTTP_201_CREATED, headers=headers)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserListView(generics.ListAPIView):
    serializer_class = UserSerializer
    permission_classes = (permissions.IsAdminUser,)
    queryset = User.objects.all()

class UserDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = UserSerializer
    permission_classes = (permissions.IsAdminUser,)
    queryset = User.objects.all()

class ProductListView(generics.ListCreateAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def get_queryset(self):
        queryset = Product.objects.all()
        category = self.request.query_params.get('category', None)
        if category:
            queryset = queryset.filter(category=category)
        return queryset

    def create(self, request, *args, **kwargs):
        if not request.user.is_staff:
            return Response(
                {'error': 'Only staff members can create products'}, 
                status=status.HTTP_403_FORBIDDEN
            )
        return super().create(request, *args, **kwargs)

class ProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

    def update(self, request, *args, **kwargs):
        if not request.user.is_staff:
            return Response(
                {'error': 'Only staff members can update products'}, 
                status=status.HTTP_403_FORBIDDEN
            )
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        if not request.user.is_staff:
            return Response(
                {'error': 'Only staff members can delete products'}, 
                status=status.HTTP_403_FORBIDDEN
            )
        return super().destroy(request, *args, **kwargs)

class CartItemView(generics.ListCreateAPIView):
    serializer_class = CartItemSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return CartItem.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        try:
            product_id = request.data.get('product_id')
            quantity = int(request.data.get('quantity', 1))

            if not product_id:
                return Response(
                    {'error': 'product_id is required'}, 
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Get the product or return 404
            product = get_object_or_404(Product, id=product_id)

            # Check if cart item already exists
            cart_item = CartItem.objects.filter(
                user=request.user,
                product=product
            ).first()

            if cart_item:
                # Update existing cart item
                cart_item.quantity += quantity
                cart_item.save()
                serializer = self.get_serializer(cart_item)
                return Response(serializer.data)
            else:
                # Create new cart item
                serializer = self.get_serializer(data=request.data)
                serializer.is_valid(raise_exception=True)
                serializer.save(user=request.user, product=product)
                return Response(
                    serializer.data, 
                    status=status.HTTP_201_CREATED
                )

        except ValueError:
            return Response(
                {'error': 'Invalid quantity'}, 
                status=status.HTTP_400_BAD_REQUEST
            )

@api_view(['GET'])
@permission_classes([permissions.IsAdminUser])
def analytics(request):
    try:
        # Get period from query params (default to 30 days)
        days = int(request.query_params.get('days', 30))
        
        # Get analytics data
        data = {
            'total_sales': Order.get_total_sales(),
            'period_sales': Order.get_sales_by_period(days),
            'order_stats': Order.get_order_stats(),
            'top_products': OrderItem.objects.values(
                'product__name'
            ).annotate(
                total_quantity=Sum('quantity'),
                total_sales=Sum('price')
            ).order_by('-total_quantity')[:5],
            'daily_sales': Order.objects.filter(
                status='completed',
                created_at__gte=timezone.now() - timedelta(days=days)
            ).values('created_at__date').annotate(
                total=Sum('total_amount')
            ).order_by('created_at__date')
        }
        
        return Response(data)
    except Exception as e:
        return Response(
            {'error': str(e)}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

class OrderListView(generics.ListCreateAPIView):
    serializer_class = OrderSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        if self.request.user.is_staff:
            return Order.objects.all().order_by('-created_at')
        return Order.objects.filter(user=self.request.user).order_by('-created_at')

    def create(self, request, *args, **kwargs):
        try:
            cart_items = CartItem.objects.filter(user=request.user)
            if not cart_items:
                return Response(
                    {'error': 'Cart is empty'}, 
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Get additional order details
            delivery_address = request.data.get('delivery_address', '')
            payment_method = request.data.get('payment_method', 'cash')
            notes = request.data.get('notes', '')

            total_amount = sum(
                item.product.price * item.quantity 
                for item in cart_items
            )

            order = Order.objects.create(
                user=request.user,
                total_amount=total_amount,
                delivery_address=delivery_address,
                payment_method=payment_method,
                notes=notes
            )

            for cart_item in cart_items:
                OrderItem.objects.create(
                    order=order,
                    product=cart_item.product,
                    quantity=cart_item.quantity,
                    price=cart_item.product.price
                )

            cart_items.delete()

            serializer = self.get_serializer(order)
            return Response(
                serializer.data, 
                status=status.HTTP_201_CREATED
            )

        except Exception as e:
            return Response(
                {'error': str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class OrderDetailView(generics.RetrieveUpdateAPIView):
    serializer_class = OrderSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        if self.request.user.is_staff:
            return Order.objects.all()
        return Order.objects.filter(user=self.request.user)

    def update(self, request, *args, **kwargs):
        try:
            if not request.user.is_staff:
                return Response(
                    {'error': 'Only staff members can update orders'}, 
                    status=status.HTTP_403_FORBIDDEN
                )
            return super().update(request, *args, **kwargs)
        except Exception as e:
            return Response(
                {'error': str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


@api_view(['DELETE', 'PUT'])
@permission_classes([permissions.IsAuthenticated])
def cart_item_detail(request, pk):
    try:
        cart_item = CartItem.objects.get(pk=pk, user=request.user)
    except CartItem.DoesNotExist:
        return Response(
            {'error': 'Cart item not found'}, 
            status=status.HTTP_404_NOT_FOUND
        )

    if request.method == 'DELETE':
        cart_item.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

    elif request.method == 'PUT':
        try:
            quantity = int(request.data.get('quantity', 1))
            if quantity <= 0:
                cart_item.delete()
                return Response(status=status.HTTP_204_NO_CONTENT)
            
            cart_item.quantity = quantity
            cart_item.save()
            return Response(CartItemSerializer(cart_item).data)
        except ValueError:
            return Response(
                {'error': 'Invalid quantity'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
