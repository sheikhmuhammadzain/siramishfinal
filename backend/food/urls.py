from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    RegisterView, 
    ProductListView,
    ProductDetailView, 
    CartItemView, 
    cart_item_detail,
    OrderListView,
    OrderDetailView,
    CustomTokenObtainPairView,
    UserListView,
    UserDetailView,
    analytics
)

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('login/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('products/', ProductListView.as_view(), name='products'),
    path('products/<int:pk>/', ProductDetailView.as_view(), name='product-detail'),
    path('cart/', CartItemView.as_view(), name='cart'),
    path('cart/<int:pk>/', cart_item_detail, name='cart-item-detail'),
    path('orders/', OrderListView.as_view(), name='order-list'),
    path('orders/<int:pk>/', OrderDetailView.as_view(), name='order-detail'),
    path('users/', UserListView.as_view(), name='user-list'),
    path('users/<int:pk>/', UserDetailView.as_view(), name='user-detail'),
    path('analytics/', analytics, name='analytics'),
]
