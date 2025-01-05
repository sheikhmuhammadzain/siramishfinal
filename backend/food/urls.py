from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import RegisterView, ProductListView, CartItemView, cart_item_detail

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('login/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('products/', ProductListView.as_view(), name='products'),
    path('cart/', CartItemView.as_view(), name='cart'),
    path('cart/<int:pk>/', cart_item_detail, name='cart-item-detail'),
]
