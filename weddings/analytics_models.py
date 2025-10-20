from django.db import models
from django.contrib.auth.models import User
from .models import Wedding, Guest, Task, Vendor, Budget

class WeddingAnalytics(models.Model):
    """Store aggregated analytics data for weddings"""
    wedding = models.OneToOneField(Wedding, on_delete=models.CASCADE, related_name='analytics')
    
    # Guest Analytics
    total_invitations_sent = models.IntegerField(default=0)
    total_confirmed = models.IntegerField(default=0)
    total_pending = models.IntegerField(default=0)
    total_declined = models.IntegerField(default=0)
    average_guests_per_invitation = models.FloatField(default=1.0)
    
    # Budget Analytics
    total_estimated_budget = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total_actual_spending = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    budget_variance = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    budget_category_breakdown = models.JSONField(default=dict)
    
    # Task Analytics
    total_tasks = models.IntegerField(default=0)
    completed_tasks = models.IntegerField(default=0)
    pending_tasks = models.IntegerField(default=0)
    overdue_tasks = models.IntegerField(default=0)
    completion_percentage = models.FloatField(default=0)
    
    # Vendor Analytics
    total_vendors = models.IntegerField(default=0)
    vendors_booked = models.IntegerField(default=0)
    average_vendor_quote = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total_vendor_cost = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    
    # Timeline Analytics
    days_until_wedding = models.IntegerField(default=0)
    weeks_until_wedding = models.IntegerField(default=0)
    completion_by_milestone = models.JSONField(default=dict)
    
    # Performance Metrics
    planning_health_score = models.FloatField(default=0)  # 0-100
    budget_health_score = models.FloatField(default=0)    # 0-100
    task_health_score = models.FloatField(default=0)      # 0-100
    guest_health_score = models.FloatField(default=0)     # 0-100
    overall_health_score = models.FloatField(default=0)   # 0-100
    
    last_updated = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Analytics - {self.wedding}"


class WeeklyAnalyticsSnapshot(models.Model):
    """Store weekly snapshots for trend analysis"""
    wedding = models.ForeignKey(Wedding, on_delete=models.CASCADE, related_name='weekly_snapshots')
    
    week_number = models.IntegerField()
    confirmed_count = models.IntegerField()
    pending_count = models.IntegerField()
    spending_to_date = models.DecimalField(max_digits=12, decimal_places=2)
    tasks_completed = models.IntegerField()
    tasks_pending = models.IntegerField()
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['week_number']
    
    def __str__(self):
        return f"Week {self.week_number} - {self.wedding}"


class GuestEngagementMetrics(models.Model):
    """Track guest engagement patterns"""
    wedding = models.ForeignKey(Wedding, on_delete=models.CASCADE, related_name='engagement_metrics')
    
    rsvp_response_rate = models.FloatField(default=0)  # percentage
    average_response_time = models.IntegerField(default=0)  # days
    relationship_breakdown = models.JSONField(default=dict)  # {family: count, friend: count}
    dietary_requirements_percentage = models.FloatField(default=0)
    group_size_distribution = models.JSONField(default=dict)  # {1: count, 2: count, etc}
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Engagement - {self.wedding}"