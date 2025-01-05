from django.shortcuts import render, get_object_or_404
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from django.contrib.auth.models import User
from .models import Product, CartItem
from .serializers import UserSerializer, ProductSerializer, CartItemSerializer

# Create your views here.

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = UserSerializer

class ProductListView(generics.ListAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = (permissions.AllowAny,)

    def get_queryset(self):
        queryset = Product.objects.all()
        category = self.request.query_params.get('category', None)
        if category:
            queryset = queryset.filter(category=category)
        return queryset

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
        except Product.DoesNotExist:
            return Response(
                {'error': 'Product not found'}, 
                status=status.HTTP_404_NOT_FOUND
            )
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
