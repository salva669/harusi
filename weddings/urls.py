from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    WeddingViewSet, GuestViewSet, TaskViewSet, BudgetViewSet,
    PhotoGalleryViewSet, PhotoViewSet, TimelineViewSet,
    VendorViewSet, InvitationTemplateViewSet
)
router = DefaultRouter()
router.register(r'weddings', WeddingViewSet, basename='wedding')

urlpatterns = [
    path('', include(router.urls)),
    path('weddings/<int:wedding_id>/guests/', GuestViewSet.as_view({'get': 'list', 'post': 'create'}), name='guest-list'),
    path('weddings/<int:wedding_id>/guests/<int:pk>/', GuestViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'}), name='guest-detail'),
    
    path('weddings/<int:wedding_id>/tasks/', TaskViewSet.as_view({'get': 'list', 'post': 'create'}), name='task-list'),
    path('weddings/<int:wedding_id>/tasks/<int:pk>/', TaskViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'}), name='task-detail'),
    
    path('weddings/<int:wedding_id>/budget/', BudgetViewSet.as_view({'get': 'list', 'post': 'create'}), name='budget-list'),
    path('weddings/<int:wedding_id>/budget/<int:pk>/', BudgetViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'}), name='budget-detail'),
    
    path('weddings/<int:wedding_id>/galleries/', PhotoGalleryViewSet.as_view({'get': 'list', 'post': 'create'}), name='gallery-list'),
    path('weddings/<int:wedding_id>/galleries/<int:pk>/', PhotoGalleryViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'}), name='gallery-detail'),
    
    path('weddings/<int:wedding_id>/galleries/<int:album_id>/photos/', PhotoViewSet.as_view({'get': 'list', 'post': 'create'}), name='photo-list'),
    path('weddings/<int:wedding_id>/galleries/<int:album_id>/photos/<int:pk>/', PhotoViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'}), name='photo-detail'),
    
    path('weddings/<int:wedding_id>/timeline/', TimelineViewSet.as_view({'get': 'list', 'post': 'create'}), name='timeline-list'),
    path('weddings/<int:wedding_id>/timeline/<int:pk>/', TimelineViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'}), name='timeline-detail'),
    path('weddings/<int:wedding_id>/timeline/<int:pk>/toggle_completed/', TimelineViewSet.as_view({'post': 'toggle_completed'}), name='timeline-toggle'),
    
    path('weddings/<int:wedding_id>/vendors/', VendorViewSet.as_view({'get': 'list', 'post': 'create'}), name='vendor-list'),
    path('weddings/<int:wedding_id>/vendors/<int:pk>/', VendorViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'}), name='vendor-detail'),
    path('weddings/<int:wedding_id>/vendors/<int:pk>/add_note/', VendorViewSet.as_view({'post': 'add_note'}), name='vendor-add-note'),
    
    path('weddings/<int:wedding_id>/invitation/', InvitationTemplateViewSet.as_view({'get': 'list', 'post': 'create'}), name='invitation-list'),
    path('weddings/<int:wedding_id>/invitation/<int:pk>/', InvitationTemplateViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'}), name='invitation-detail'),
]
