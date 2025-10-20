from django.shortcuts import render, get_object_or_404
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import (
    Wedding, Guest, Task, Budget, PhotoGallery, Photo,
    Timeline, Vendor, VendorNote, InvitationTemplate
)
from .serializers import (
    WeddingSerializer, GuestSerializer, TaskSerializer, BudgetSerializer,
    PhotoGallerySerializer, PhotoSerializer, TimelineSerializer,
    VendorSerializer, VendorNoteSerializer, InvitationTemplateSerializer
)
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

class PhotoGalleryViewSet(viewsets.ModelViewSet):
    serializer_class = PhotoGallerySerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        wedding_id = self.kwargs.get('wedding_id')
        return PhotoGallery.objects.filter(wedding_id=wedding_id, wedding__user=self.request.user)
    
    def perform_create(self, serializer):
        wedding_id = self.kwargs.get('wedding_id')
        wedding = get_object_or_404(Wedding, id=wedding_id, user=self.request.user)
        serializer.save(wedding=wedding)


class PhotoViewSet(viewsets.ModelViewSet):
    serializer_class = PhotoSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        album_id = self.kwargs.get('album_id')
        return Photo.objects.filter(album_id=album_id, album__wedding__user=self.request.user)
    
    def perform_create(self, serializer):
        album_id = self.kwargs.get('album_id')
        album = get_object_or_404(PhotoGallery, id=album_id, wedding__user=self.request.user)
        serializer.save(album=album, uploaded_by=self.request.user)


class TimelineViewSet(viewsets.ModelViewSet):
    serializer_class = TimelineSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        wedding_id = self.kwargs.get('wedding_id')
        return Timeline.objects.filter(wedding_id=wedding_id, wedding__user=self.request.user)
    
    def perform_create(self, serializer):
        wedding_id = self.kwargs.get('wedding_id')
        wedding = get_object_or_404(Wedding, id=wedding_id, user=self.request.user)
        serializer.save(wedding=wedding)
    
    @action(detail=True, methods=['post'])
    def toggle_completed(self, request, pk=None, **kwargs):
        event = self.get_object()
        event.is_completed = not event.is_completed
        event.save()
        return Response({'status': 'completed' if event.is_completed else 'pending'})


class VendorViewSet(viewsets.ModelViewSet):
    serializer_class = VendorSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        wedding_id = self.kwargs.get('wedding_id')
        return Vendor.objects.filter(wedding_id=wedding_id, wedding__user=self.request.user)
    
    def perform_create(self, serializer):
        wedding_id = self.kwargs.get('wedding_id')
        wedding = get_object_or_404(Wedding, id=wedding_id, user=self.request.user)
        serializer.save(wedding=wedding)
    
    @action(detail=True, methods=['post'])
    def add_note(self, request, pk=None, **kwargs):
        vendor = self.get_object()
        serializer = VendorNoteSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(vendor=vendor, created_by=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class InvitationTemplateViewSet(viewsets.ModelViewSet):
    serializer_class = InvitationTemplateSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        wedding_id = self.kwargs.get('wedding_id')
        return InvitationTemplate.objects.filter(wedding_id=wedding_id, wedding__user=self.request.user)
    
    def perform_create(self, serializer):
        wedding_id = self.kwargs.get('wedding_id')
        wedding = get_object_or_404(Wedding, id=wedding_id, user=self.request.user)
        serializer.save(wedding=wedding)
