from django.db import models
from django.contrib.auth.models import User

# Create your models here.

class Product(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    image = models.URLField(blank=True, null=True)
    category = models.CharField(max_length=100, default='main')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class CartItem(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.product.name}"

class Order(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    delivery_address = models.TextField(blank=True, null=True)
    payment_method = models.CharField(max_length=50, default='cash')
    notes = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"Order #{self.id} - {self.user.username}"

    @classmethod
    def get_total_sales(cls):
        return cls.objects.filter(status='completed').aggregate(
            total=models.Sum('total_amount')
        )['total'] or 0

    @classmethod
    def get_sales_by_period(cls, days):
        from django.utils import timezone
        from datetime import timedelta
        start_date = timezone.now() - timedelta(days=days)
        return cls.objects.filter(
            status='completed',
            created_at__gte=start_date
        ).aggregate(
            total=models.Sum('total_amount')
        )['total'] or 0

    @classmethod
    def get_order_stats(cls):
        return {
            'total': cls.objects.count(),
            'pending': cls.objects.filter(status='pending').count(),
            'processing': cls.objects.filter(status='processing').count(),
            'completed': cls.objects.filter(status='completed').count(),
            'cancelled': cls.objects.filter(status='cancelled').count(),
        }

class OrderItem(models.Model):
    order = models.ForeignKey(Order, related_name='items', on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField(default=1)
    price = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"{self.quantity}x {self.product.name}"
