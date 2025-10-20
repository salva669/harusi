from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.http import FileResponse
from django.shortcuts import get_object_or_404
from .models import Wedding
from .pdf_service import WeddingPDFGenerator

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def download_guest_list_pdf(request, wedding_id):
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    buffer = WeddingPDFGenerator.generate_guest_list_pdf(wedding)
    return FileResponse(
        buffer,
        as_attachment=True,
        filename=f'guest_list_{wedding.id}.pdf',
        content_type='application/pdf'
    )

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def download_budget_report_pdf(request, wedding_id):
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    buffer = WeddingPDFGenerator.generate_budget_report_pdf(wedding)
    return FileResponse(
        buffer,
        as_attachment=True,
        filename=f'budget_report_{wedding.id}.pdf',
        content_type='application/pdf'
    )

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def download_timeline_pdf(request, wedding_id):
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    buffer = WeddingPDFGenerator.generate_timeline_pdf(wedding)
    return FileResponse(
        buffer,
        as_attachment=True,
        filename=f'timeline_{wedding.id}.pdf',
        content_type='application/pdf'
    )

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def download_vendor_list_pdf(request, wedding_id):
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    buffer = WeddingPDFGenerator.generate_vendor_list_pdf(wedding)
    return FileResponse(
        buffer,
        as_attachment=True,
        filename=f'vendor_list_{wedding.id}.pdf',
        content_type='application/pdf'
    )

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def download_invitation_pdf(request, wedding_id):
    from .models import InvitationTemplate
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    invitation = get_object_or_404(InvitationTemplate, wedding=wedding)
    buffer = WeddingPDFGenerator.generate_invitation_card_pdf(invitation)
    return FileResponse(
        buffer,
        as_attachment=True,
        filename=f'invitation_{wedding.id}.pdf',
        content_type='application/pdf'
    )