from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Wedding, Guest, Task, Budget

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