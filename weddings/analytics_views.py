from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import Wedding, GuestPledge
from .models import (
    WeddingAnalytics, WeeklyAnalyticsSnapshot, GuestEngagementMetrics
)
from .analytics_serializers import (
    WeddingAnalyticsSerializer, WeeklyAnalyticsSnapshotSerializer,
    GuestEngagementMetricsSerializer
)
from .analytics_service import WeddingAnalyticsService

# ============================================
# MAIN ENDPOINT - This is what Flutter calls
# ============================================
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def wedding_analytics(request, wedding_id):
    """
    Main analytics endpoint that Flutter app calls
    Endpoint: /api/weddings/<id>/analytics/
    """
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    
    # Calculate fresh analytics
    analytics = WeddingAnalyticsService.calculate_analytics(wedding)
    
    # Return data in format Flutter expects
    return Response({
        'total_invitations_sent': analytics.total_invitations_sent,
        'total_confirmed': analytics.total_confirmed,
        'total_pending': analytics.total_pending,
        'total_declined': analytics.total_declined,
        'average_guests_per_invitation': float(analytics.average_guests_per_invitation),
        'total_estimated_budget': str(analytics.total_estimated_budget),
        'total_actual_spending': str(analytics.total_actual_spending),
        'budget_variance': str(analytics.budget_variance),
        'budget_category_breakdown': analytics.budget_category_breakdown,
        'total_tasks': analytics.total_tasks,
        'completed_tasks': analytics.completed_tasks,
        'pending_tasks': analytics.pending_tasks,
        'overdue_tasks': analytics.overdue_tasks,
        'completion_percentage': float(analytics.completion_percentage),
        'total_vendors': analytics.total_vendors,
        'vendors_booked': analytics.vendors_booked,
        'average_vendor_quote': str(analytics.average_vendor_quote),
        'total_vendor_cost': str(analytics.total_vendor_cost),
        'days_until_wedding': analytics.days_until_wedding,
        'weeks_until_wedding': analytics.weeks_until_wedding,
        'planning_health_score': float(analytics.planning_health_score),
        'budget_health_score': float(analytics.budget_health_score),
        'task_health_score': float(analytics.task_health_score),
        'guest_health_score': float(analytics.guest_health_score),
        'overall_health_score': float(analytics.overall_health_score),
    })


# ============================================
# PLEDGE SUMMARY ENDPOINT
# ============================================
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def pledge_summary(request, wedding_id):
    """
    Pledge summary endpoint
    Endpoint: /api/weddings/<id>/pledges/summary/
    """
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    pledges = wedding.pledges.all()
    
    from decimal import Decimal
    total_pledged = sum(p.pledged_amount for p in pledges) or Decimal(0)
    total_paid = sum(p.paid_amount for p in pledges) or Decimal(0)
    total_balance = sum(p.balance for p in pledges) or Decimal(0)
    
    return Response({
        'total_pledged': str(total_pledged),
        'total_paid': str(total_paid),
        'total_balance': str(total_balance),
        'total_pledgers': pledges.count(),
        'fully_paid_count': pledges.filter(payment_status='paid').count(),
        'partially_paid_count': pledges.filter(payment_status='partial').count(),
        'unpaid_count': pledges.filter(payment_status='pledged').count(),
    })


# ============================================
# OTHER ANALYTICS ENDPOINTS (Optional)
# ============================================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_analytics(request, wedding_id):
    """Get comprehensive analytics for a wedding"""
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    
    # Calculate fresh analytics
    analytics = WeddingAnalyticsService.calculate_analytics(wedding)
    engagement = WeddingAnalyticsService.calculate_engagement_metrics(wedding)
    comparison = WeddingAnalyticsService.get_comparison_data(wedding)
    
    serializer = WeddingAnalyticsSerializer(analytics)
    engagement_serializer = GuestEngagementMetricsSerializer(engagement)
    
    return Response({
        'analytics': serializer.data,
        'engagement': engagement_serializer.data,
        'comparison': comparison,
        'health_report': {
            'budget_health': analytics.budget_health_score,
            'task_health': analytics.task_health_score,
            'guest_health': analytics.guest_health_score,
            'planning_health': analytics.planning_health_score,
            'overall_health': analytics.overall_health_score
        }
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_trend_data(request, wedding_id):
    """Get trend data from weekly snapshots"""
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    
    snapshots = WeeklyAnalyticsSnapshot.objects.filter(wedding=wedding).order_by('week_number')
    serializer = WeeklyAnalyticsSnapshotSerializer(snapshots, many=True)
    
    return Response({
        'snapshots': serializer.data,
        'total_weeks': snapshots.count()
    })


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_snapshot(request, wedding_id):
    """Manually create a weekly snapshot"""
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    
    snapshot = WeddingAnalyticsService.create_weekly_snapshot(wedding)
    serializer = WeeklyAnalyticsSnapshotSerializer(snapshot)
    
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_category_breakdown(request, wedding_id):
    """Get detailed budget category breakdown"""
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    
    analytics = wedding.analytics
    categories = analytics.budget_category_breakdown
    
    # Add percentage calculations
    total = analytics.total_estimated_budget
    breakdown = []
    for cat, data in categories.items():
        breakdown.append({
            'category': cat,
            'estimated': data['estimated'],
            'actual': data['actual'],
            'variance': data['estimated'] - data['actual'],
            'percentage_of_budget': (data['estimated'] / float(total) * 100) if total > 0 else 0,
            'item_count': data['count']
        })
    
    return Response({'breakdown': breakdown})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_timeline_status(request, wedding_id):
    """Get timeline event completion status"""
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    
    analytics = wedding.analytics
    timeline_status = analytics.completion_by_milestone
    
    total_events = len(timeline_status)
    completed_events = sum(1 for event in timeline_status.values() if event.get('completed'))
    completion_rate = (completed_events / total_events * 100) if total_events > 0 else 0
    
    return Response({
        'events': timeline_status,
        'total_events': total_events,
        'completed_events': completed_events,
        'completion_rate': completion_rate,
        'days_until_wedding': analytics.days_until_wedding,
        'weeks_until_wedding': analytics.weeks_until_wedding
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_guest_analytics(request, wedding_id):
    """Get detailed guest analytics"""
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    
    analytics = wedding.analytics
    engagement = wedding.engagement_metrics.first() or WeddingAnalyticsService.calculate_engagement_metrics(wedding)
    
    total_guests = sum(guest.number_of_guests for guest in wedding.guests.all())
    confirmed_guests = sum(guest.number_of_guests for guest in wedding.guests.filter(rsvp_status='confirmed'))
    
    return Response({
        'invitations_sent': analytics.total_invitations_sent,
        'confirmed': analytics.total_confirmed,
        'pending': analytics.total_pending,
        'declined': analytics.total_declined,
        'average_per_invitation': analytics.average_guests_per_invitation,
        'total_guest_count': total_guests,
        'confirmed_guest_count': confirmed_guests,
        'response_rate': engagement.rsvp_response_rate,
        'relationship_breakdown': engagement.relationship_breakdown,
        'dietary_requirements': engagement.dietary_requirements_percentage,
        'group_size_distribution': engagement.group_size_distribution
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_health_scores(request, wedding_id):
    """Get individual health scores"""
    wedding = get_object_or_404(Wedding, id=wedding_id, user=request.user)
    
    analytics = wedding.analytics
    
    return Response({
        'budget_health': {
            'score': analytics.budget_health_score,
            'message': 'On track' if analytics.budget_health_score >= 80 else 'Watch spending',
            'variance': float(analytics.budget_variance),
            'percentage_spent': (float(analytics.total_actual_spending) / float(analytics.total_estimated_budget) * 100) if analytics.total_estimated_budget > 0 else 0
        },
        'task_health': {
            'score': analytics.task_health_score,
            'message': 'On track' if analytics.task_health_score >= 80 else 'Behind schedule',
            'completion': analytics.completion_percentage,
            'overdue': analytics.overdue_tasks,
            'pending': analytics.pending_tasks
        },
        'guest_health': {
            'score': analytics.guest_health_score,
            'message': 'Good response' if analytics.guest_health_score >= 70 else 'Follow up needed',
            'response_rate': (analytics.total_confirmed + analytics.total_declined) / analytics.total_invitations_sent * 100 if analytics.total_invitations_sent > 0 else 0,
            'pending_responses': analytics.total_pending
        },
        'planning_health': {
            'score': analytics.planning_health_score,
            'message': 'Good progress' if analytics.planning_health_score >= 70 else 'Catch up on milestones',
            'days_until_wedding': analytics.days_until_wedding,
            'weeks_until_wedding': analytics.weeks_until_wedding
        },
        'overall_health': {
            'score': analytics.overall_health_score,
            'status': 'Excellent' if analytics.overall_health_score >= 85 else 'Good' if analytics.overall_health_score >= 70 else 'Needs Attention'
        }
    })
