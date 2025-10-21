from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Sum, Q
from .models import Wedding, Guest, GuestPledge, PledgePayment
from .serializers import GuestPledgeSerializer, PledgePaymentSerializer

class GuestPledgeViewSet(viewsets.ModelViewSet):
    serializer_class = GuestPledgeSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        wedding_id = self.kwargs.get('wedding_id')
        return GuestPledge.objects.filter(wedding_id=wedding_id, wedding__user=self.request.user)
    
    def perform_create(self, serializer):
        wedding_id = self.kwargs.get('wedding_id')
        wedding = get_object_or_404(Wedding, id=wedding_id, user=self.request.user)
        serializer.save(wedding=wedding, created_by=self.request.user)
    
    @action(detail=False, methods=['get'])
    def summary(self, request, wedding_id=None):
        """Get pledge summary for the wedding"""
        pledges = self.get_queryset()
        
        total_pledged = pledges.aggregate(Sum('pledged_amount'))['pledged_amount__sum'] or 0
        total_paid = pledges.aggregate(Sum('paid_amount'))['paid_amount__sum'] or 0
        total_balance = pledges.aggregate(Sum('balance'))['balance__sum'] or 0
        
        status_breakdown = {
            'pledged': pledges.filter(payment_status='pledged').count(),
            'partial': pledges.filter(payment_status='partial').count(),
            'paid': pledges.filter(payment_status='paid').count(),
            'cancelled': pledges.filter(payment_status='cancelled').count(),
        }
        
        return Response({
            'total_pledged': total_pledged,
            'total_paid': total_paid,
            'total_balance': total_balance,
            'collection_rate': (total_paid / total_pledged * 100) if total_pledged > 0 else 0,
            'status_breakdown': status_breakdown,
            'total_pledges': pledges.count()
        })
    
    @action(detail=True, methods=['post'])
    def record_payment(self, request, pk=None, **kwargs):
        """Record a payment towards a pledge"""
        pledge = self.get_object()
        
        serializer = PledgePaymentSerializer(data=request.data)
        if serializer.is_valid():
            payment = serializer.save(pledge=pledge, recorded_by=request.user)
            
            # Update pledge paid amount
            pledge.paid_amount += payment.amount
            pledge.save()
            
            return Response(GuestPledgeSerializer(pledge).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PledgePaymentViewSet(viewsets.ModelViewSet):
    serializer_class = PledgePaymentSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        pledge_id = self.kwargs.get('pledge_id')
        return PledgePayment.objects.filter(
            pledge_id=pledge_id,
            pledge__wedding__user=self.request.user
        )
    
    def perform_create(self, serializer):
        pledge_id = self.kwargs.get('pledge_id')
        pledge = get_object_or_404(GuestPledge, id=pledge_id, wedding__user=self.request.user)
        
        payment = serializer.save(pledge=pledge, recorded_by=self.request.user)
        
        # Update pledge total
        pledge.paid_amount += payment.amount
        pledge.save()