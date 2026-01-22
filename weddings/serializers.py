from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    Wedding, Guest, Task, Budget, PhotoGallery, Photo,
    Timeline, Vendor, VendorNote, InvitationTemplate, GuestPledge, PledgePayment,
    WeddingAnalytics, WeeklyAnalyticsSnapshot, GuestEngagementMetrics
)

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']


class BudgetSerializer(serializers.ModelSerializer):
    class Meta:
        model = Budget
        fields = ['id', 'category', 'item_name', 'estimated_cost', 'actual_cost', 'notes', 'created_at', 'wedding']
        read_only_fields = ['id', 'created_at', 'wedding']


class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ['id', 'title', 'description', 'priority', 'status', 'due_date', 'assigned_to', 'cost', 'created_at', 'updated_at', 'wedding']
        read_only_fields = ['id', 'created_at', 'updated_at', 'wedding']


class GuestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Guest
        fields = ['id', 'wedding', 'name', 'email', 'phone', 'relationship', 'rsvp_status', 'number_of_guests', 'dietary_restrictions', 'created_at']
        read_only_fields = ['id', 'wedding', 'created_at']  


class WeddingSerializer(serializers.ModelSerializer):
    guests = GuestSerializer(many=True, read_only=True)
    tasks = TaskSerializer(many=True, read_only=True)
    budget_items = BudgetSerializer(many=True, read_only=True)
    
    class Meta:
        model = Wedding
        fields = ['id', 'user', 'bride_name', 'groom_name', 'wedding_date', 'venue', 
                  'budget', 'status', 'description', 'guests', 'tasks', 'budget_items', 
                  'created_at', 'updated_at']
        read_only_fields = ['user', 'created_at', 'updated_at']

class PhotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Photo
        fields = '__all__'


class PhotoGallerySerializer(serializers.ModelSerializer):
    photos = PhotoSerializer(many=True, read_only=True)
    
    class Meta:
        model = PhotoGallery
        fields = '__all__'


class TimelineSerializer(serializers.ModelSerializer):
    days_until = serializers.SerializerMethodField()
    
    def get_days_until(self, obj):
        from datetime import date
        today = date.today()
        delta = (obj.date - today).days
        return delta
    
    class Meta:
        model = Timeline
        fields = '__all__'


class VendorNoteSerializer(serializers.ModelSerializer):
    created_by_username = serializers.CharField(source='created_by.username', read_only=True)
    
    class Meta:
        model = VendorNote
        fields = '__all__'


class VendorSerializer(serializers.ModelSerializer):
    note_entries = VendorNoteSerializer(many=True, read_only=True)
    remaining_amount = serializers.SerializerMethodField()
    
    def get_remaining_amount(self, obj):
        if obj.final_amount and obj.deposit_paid:
            return obj.final_amount - obj.deposit_paid
        return obj.final_amount
    
    class Meta:
        model = Vendor
        fields = '__all__'


class InvitationTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = InvitationTemplate
        fields = '__all__'

class PledgePaymentSerializer(serializers.ModelSerializer):
    recorded_by_username = serializers.CharField(source='recorded_by.username', read_only=True)
    
    class Meta:
        model = PledgePayment
        fields = ['id', 'pledge', 'amount', 'payment_date', 'payment_method', 
                  'reference_number', 'notes', 'recorded_by', 'recorded_by_username', 'created_at']
        read_only_fields = ['id', 'created_at', 'recorded_by', 'pledge']


class GuestPledgeSerializer(serializers.ModelSerializer):
    guest_name = serializers.CharField(source='guest.name', read_only=True)
    payments = PledgePaymentSerializer(many=True, read_only=True)
    payment_progress = serializers.SerializerMethodField()
    
    def get_payment_progress(self, obj):
        if obj.pledged_amount > 0:
            return (obj.paid_amount / obj.pledged_amount * 100)
        return 0
    
    class Meta:
        model = GuestPledge
        fields = ['id', 'guest', 'guest_name', 'wedding', 'pledged_amount', 'paid_amount', 
                  'balance', 'payment_status', 'payment_method',
                  'pledge_date', 'payment_deadline', 'notes', 'payments', 'payment_progress',
                  'created_at', 'updated_at']
        read_only_fields = ['id', 'balance', 'payment_status', 'created_at', 'updated_at', 'wedding']

class WeddingAnalyticsSerializer(serializers.ModelSerializer):
    class Meta:
        model = WeddingAnalytics
        fields = [
            'total_invitations_sent',
            'total_confirmed',
            'total_pending',
            'total_declined',
            'average_guests_per_invitation',
            'total_estimated_budget',
            'total_actual_spending',
            'budget_variance',
            'budget_category_breakdown',
            'total_tasks',
            'completed_tasks',
            'pending_tasks',
            'overdue_tasks',
            'completion_percentage',
            'total_vendors',
            'vendors_booked',
            'average_vendor_quote',
            'total_vendor_cost',
            'days_until_wedding',
            'weeks_until_wedding',
            'planning_health_score',
            'budget_health_score',
            'task_health_score',
            'guest_health_score',
            'overall_health_score',
        ]

class WeeklyAnalyticsSnapshotSerializer(serializers.ModelSerializer):
    class Meta:
        model = WeeklyAnalyticsSnapshot
        fields = '__all__'

class GuestEngagementMetricsSerializer(serializers.ModelSerializer):
    class Meta:
        model = GuestEngagementMetrics
        fields = '__all__'