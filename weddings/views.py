from django.shortcuts import render, get_object_or_404
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Wedding, Guest, Task, Budget
from .serializers import WeddingSerializer, GuestSerializer, TaskSerializer, BudgetSerializer

# Create your views here.
class WeddingViewSet(viewsets.ModelViewSet):
    serializer_class = WeddingSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        return Wedding.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    @action(detail=True, methods=['get'])
    def summary(self, request, pk=None):
        wedding = self.get_object()
        total_guests = wedding.guests.count()
        confirmed_guests = wedding.guests.filter(rsvp_status='confirmed').count()
        total_tasks = wedding.tasks.count()
        completed_tasks = wedding.tasks.filter(status='done').count()
        
        return Response({
            'total_guests': total_guests,
            'confirmed_guests': confirmed_guests,
            'total_tasks': total_tasks,
            'completed_tasks': completed_tasks,
            'budget': wedding.budget,
        })


class GuestViewSet(viewsets.ModelViewSet):
    serializer_class = GuestSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        wedding_id = self.kwargs.get('wedding_id')
        return Guest.objects.filter(wedding_id=wedding_id, wedding__user=self.request.user)
    
    def perform_create(self, serializer):
        wedding_id = self.kwargs.get('wedding_id')
        wedding = get_object_or_404(Wedding, id=wedding_id, user=self.request.user)
        serializer.save(wedding=wedding)


class TaskViewSet(viewsets.ModelViewSet):
    serializer_class = TaskSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        wedding_id = self.kwargs.get('wedding_id')
        return Task.objects.filter(wedding_id=wedding_id, wedding__user=self.request.user)
    
    def perform_create(self, serializer):
        wedding_id = self.kwargs.get('wedding_id')
        wedding = get_object_or_404(Wedding, id=wedding_id, user=self.request.user)
        serializer.save(wedding=wedding)


class BudgetViewSet(viewsets.ModelViewSet):
    serializer_class = BudgetSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        wedding_id = self.kwargs.get('wedding_id')
        return Budget.objects.filter(wedding_id=wedding_id, wedding__user=self.request.user)
    
    def perform_create(self, serializer):
        wedding_id = self.kwargs.get('wedding_id')
        wedding = get_object_or_404(Wedding, id=wedding_id, user=self.request.user)
        serializer.save(wedding=wedding)
