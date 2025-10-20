from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    Wedding, Guest, Task, Budget, PhotoGallery, Photo,
    Timeline, Vendor, VendorNote, InvitationTemplate
)

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']


class BudgetSerializer(serializers.ModelSerializer):
    class Meta:
        model = Budget
        fields = '__all__'


class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = '__all__'


class GuestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Guest
        fields = '__all__'


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
    notes = VendorNoteSerializer(many=True, read_only=True)
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