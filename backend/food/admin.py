from django.contrib import admin
from django.utils.html import format_html
from django.urls import path
from django.template.response import TemplateResponse
from django.db.models import Sum, Count
from django.utils import timezone
from datetime import timedelta
from .models import Product, CartItem, Order, OrderItem

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
	list_display = ('name', 'price', 'category', 'created_at')
	list_filter = ('category',)
	search_fields = ('name', 'description')

@admin.register(CartItem)
class CartItemAdmin(admin.ModelAdmin):
	list_display = ('user', 'product', 'quantity', 'created_at')
	list_filter = ('user',)
	search_fields = ('user__username', 'product__name')

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
	list_display = ('id', 'user', 'total_amount', 'status', 'payment_method', 'created_at')
	list_filter = ('status', 'payment_method', 'created_at')
	search_fields = ('user__username', 'delivery_address')
	readonly_fields = ('created_at', 'updated_at')
	
	def get_urls(self):
		urls = super().get_urls()
		custom_urls = [
			path('analytics/', self.admin_site.admin_view(self.analytics_view), name='order-analytics'),
		]
		return custom_urls + urls

	def analytics_view(self, request):
		# Get analytics data
		context = {
			'title': 'Order Analytics',
			'total_sales': Order.get_total_sales(),
			'today_sales': Order.get_sales_by_period(1),
			'week_sales': Order.get_sales_by_period(7),
			'month_sales': Order.get_sales_by_period(30),
			'order_stats': Order.get_order_stats(),
			'top_products': OrderItem.objects.values(
				'product__name'
			).annotate(
				total_quantity=Sum('quantity'),
				total_sales=Sum('price')
			).order_by('-total_quantity')[:5],
		}
		
		return TemplateResponse(request, 'admin/order_analytics.html', context)

	def changelist_view(self, request, extra_context=None):
		# Add analytics summary to the changelist view
		response = super().changelist_view(request, extra_context)
		try:
			if hasattr(response, 'context_data'):
				response.context_data['analytics_summary'] = {
					'total_orders': Order.objects.count(),
					'total_sales': Order.get_total_sales(),
					'today_sales': Order.get_sales_by_period(1),
				}
		except Exception:
			pass
		return response

	actions = ['mark_as_processing', 'mark_as_completed', 'mark_as_cancelled']

	def mark_as_processing(self, request, queryset):
		queryset.update(status='processing')
	mark_as_processing.short_description = "Mark selected orders as processing"

	def mark_as_completed(self, request, queryset):
		queryset.update(status='completed')
	mark_as_completed.short_description = "Mark selected orders as completed"

	def mark_as_cancelled(self, request, queryset):
		queryset.update(status='cancelled')
	mark_as_cancelled.short_description = "Mark selected orders as cancelled"

@admin.register(OrderItem)
class OrderItemAdmin(admin.ModelAdmin):
	list_display = ('order', 'product', 'quantity', 'price')
	list_filter = ('order__status',)
	search_fields = ('order__id', 'product__name')