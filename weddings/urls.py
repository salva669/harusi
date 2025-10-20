from django.urls import path, include
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .email_service import WeddingEmailService
from .models import Guest, InvitationTemplate, Vendor
from rest_framework.routers import DefaultRouter
from .views import (
    WeddingViewSet, GuestViewSet, TaskViewSet, BudgetViewSet,
    PhotoGalleryViewSet, PhotoViewSet, TimelineViewSet,
    VendorViewSet, InvitationTemplateViewSet
)
from .pdf_views import (
    download_guest_list_pdf,
    download_budget_report_pdf,
    download_timeline_pdf,
    download_vendor_list_pdf,
    download_invitation_pdf,
)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_rsvp_reminders(request, wedding_id):
    from .models import Wedding
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    guests = wedding.guests.filter(rsvp_status='pending')
    
    count = 0
    for guest in guests:
        if WeddingEmailService.send_rsvp_reminder(guest):
            count += 1
    
    return Response({'sent': count, 'total': guests.count()})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_invitations(request, wedding_id):
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    invitation = get_object_or_404(InvitationTemplate, wedding=wedding)
    guests = wedding.guests.all()
    
    count = 0
    for guest in guests:
        if WeddingEmailService.send_invitation_email(guest, invitation):
            count += 1
    
    return Response({'sent': count, 'total': guests.count()})

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

    path('weddings/<int:wedding_id>/pdf/guest-list/', download_guest_list_pdf, name='pdf-guest-list'),
    path('weddings/<int:wedding_id>/pdf/budget/', download_budget_report_pdf, name='pdf-budget'),
    path('weddings/<int:wedding_id>/pdf/timeline/', download_timeline_pdf, name='pdf-timeline'),
    path('weddings/<int:wedding_id>/pdf/vendors/', download_vendor_list_pdf, name='pdf-vendors'),
    path('weddings/<int:wedding_id>/pdf/invitation/', download_invitation_pdf, name='pdf-invitation'),

    path('weddings/<int:wedding_id>/email/rsvp-reminders/', send_rsvp_reminders, name='send-rsvp'),
    path('weddings/<int:wedding_id>/email/send-invitations/', send_invitations, name='send-invitations'),
]
