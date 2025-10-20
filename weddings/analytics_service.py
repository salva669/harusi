from datetime import datetime, date, timedelta
from django.utils import timezone
from decimal import Decimal
from .models import (
    Wedding, Guest, Task, Vendor, Budget, 
    WeddingAnalytics, WeeklyAnalyticsSnapshot, GuestEngagementMetrics
)

class WeddingAnalyticsService:
    
    @staticmethod
    def calculate_analytics(wedding):
        """Calculate all analytics for a wedding"""
        analytics, created = WeddingAnalytics.objects.get_or_create(wedding=wedding)
        
        # Calculate guest analytics
        WeddingAnalyticsService._calculate_guest_analytics(wedding, analytics)
        
        # Calculate budget analytics
        WeddingAnalyticsService._calculate_budget_analytics(wedding, analytics)
        
        # Calculate task analytics
        WeddingAnalyticsService._calculate_task_analytics(wedding, analytics)
        
        # Calculate vendor analytics
        WeddingAnalyticsService._calculate_vendor_analytics(wedding, analytics)
        
        # Calculate timeline analytics
        WeddingAnalyticsService._calculate_timeline_analytics(wedding, analytics)
        
        # Calculate health scores
        WeddingAnalyticsService._calculate_health_scores(analytics)
        
        analytics.save()
        return analytics
    
    @staticmethod
    def _calculate_guest_analytics(wedding, analytics):
        """Calculate guest-related metrics"""
        guests = wedding.guests.all()
        
        analytics.total_invitations_sent = guests.count()
        analytics.total_confirmed = guests.filter(rsvp_status='confirmed').count()
        analytics.total_pending = guests.filter(rsvp_status='pending').count()
        analytics.total_declined = guests.filter(rsvp_status='declined').count()
        
        if guests.count() > 0:
            analytics.average_guests_per_invitation = guests.aggregate(
                avg=models.Avg('number_of_guests')
            )['avg'] or 1.0
    
    @staticmethod
    def _calculate_budget_analytics(wedding, analytics):
        """Calculate budget-related metrics"""
        budget_items = wedding.budget_items.all()
        
        analytics.total_estimated_budget = sum([
            Decimal(item.estimated_cost) for item in budget_items
        ]) or Decimal(0)
        
        analytics.total_actual_spending = sum([
            Decimal(item.actual_cost or 0) for item in budget_items
        ]) or Decimal(0)
        
        analytics.budget_variance = (
            analytics.total_actual_spending - analytics.total_estimated_budget
        )
        
        # Category breakdown
        category_breakdown = {}
        for item in budget_items:
            if item.category not in category_breakdown:
                category_breakdown[item.category] = {
                    'estimated': 0,
                    'actual': 0,
                    'count': 0
                }
            category_breakdown[item.category]['estimated'] += float(item.estimated_cost)
            category_breakdown[item.category]['actual'] += float(item.actual_cost or 0)
            category_breakdown[item.category]['count'] += 1
        
        analytics.budget_category_breakdown = category_breakdown
    
    @staticmethod
    def _calculate_task_analytics(wedding, analytics):
        """Calculate task-related metrics"""
        tasks = wedding.tasks.all()
        
        analytics.total_tasks = tasks.count()
        analytics.completed_tasks = tasks.filter(status='done').count()
        analytics.pending_tasks = tasks.filter(status__in=['todo', 'in_progress']).count()
        
        # Calculate overdue tasks
        today = date.today()
        overdue_tasks = tasks.filter(
            due_date__lt=today,
            status__in=['todo', 'in_progress']
        ).count()
        analytics.overdue_tasks = overdue_tasks
        
        if analytics.total_tasks > 0:
            analytics.completion_percentage = (
                analytics.completed_tasks / analytics.total_tasks * 100
            )
    
    @staticmethod
    def _calculate_vendor_analytics(wedding, analytics):
        """Calculate vendor-related metrics"""
        vendors = wedding.vendors.all()
        
        analytics.total_vendors = vendors.count()
        analytics.vendors_booked = vendors.filter(status='booked').count()
        
        quotes = [float(v.quote) for v in vendors if v.quote]
        if quotes:
            analytics.average_vendor_quote = Decimal(sum(quotes) / len(quotes))
        
        analytics.total_vendor_cost = sum([
            Decimal(v.final_amount or v.quote or 0) for v in vendors
        ]) or Decimal(0)
    
    @staticmethod
    def _calculate_timeline_analytics(wedding, analytics):
        """Calculate timeline-related metrics"""
        today = date.today()
        wedding_date = wedding.wedding_date
        
        days_until = (wedding_date - today).days
        analytics.days_until_wedding = max(days_until, 0)
        analytics.weeks_until_wedding = analytics.days_until_wedding // 7
        
        # Calculate completion by milestone
        events = wedding.timeline_events.all().order_by('date')
        milestone_completion = {}
        for event in events:
            milestone_completion[event.get_event_type_display()] = {
                'completed': event.is_completed,
                'date': event.date.isoformat(),
                'days_until': (event.date - today).days
            }
        analytics.completion_by_milestone = milestone_completion
    
    @staticmethod
    def _calculate_health_scores(analytics):
        """Calculate health scores (0-100)"""
        
        # Budget health: 100 if under budget, decrease as overspend increases
        if analytics.total_estimated_budget > 0:
            budget_ratio = float(analytics.total_actual_spending) / float(analytics.total_estimated_budget)
            analytics.budget_health_score = max(0, 100 - (budget_ratio - 1) * 100)
        else:
            analytics.budget_health_score = 100
        
        # Task health: based on completion and overdue tasks
        if analytics.total_tasks > 0:
            completion_score = analytics.completion_percentage
            overdue_penalty = (analytics.overdue_tasks / analytics.total_tasks) * 20
            analytics.task_health_score = max(0, completion_score - overdue_penalty)
        else:
            analytics.task_health_score = 100
        
        # Guest health: based on RSVP response rate
        if analytics.total_invitations_sent > 0:
            response_rate = (analytics.total_confirmed + analytics.total_declined) / analytics.total_invitations_sent * 100
            analytics.guest_health_score = response_rate
        else:
            analytics.guest_health_score = 100
        
        # Planning health: based on completion by milestone
        if analytics.completion_by_milestone:
            completed = sum(1 for m in analytics.completion_by_milestone.values() if m.get('completed'))
            analytics.planning_health_score = (completed / len(analytics.completion_by_milestone)) * 100
        else:
            analytics.planning_health_score = 100
        
        # Overall health: average of all scores
        analytics.overall_health_score = (
            analytics.budget_health_score +
            analytics.task_health_score +
            analytics.guest_health_score +
            analytics.planning_health_score
        ) / 4
    
    @staticmethod
    def create_weekly_snapshot(wedding):
        """Create a weekly analytics snapshot"""
        from datetime import datetime
        week_number = datetime.now().isocalendar()[1]
        
        confirmed = wedding.guests.filter(rsvp_status='confirmed').count()
        pending = wedding.guests.filter(rsvp_status='pending').count()
        
        spending = sum([
            float(item.actual_cost or 0) 
            for item in wedding.budget_items.all()
        ])
        
        tasks_completed = wedding.tasks.filter(status='done').count()
        tasks_pending = wedding.tasks.filter(status__in=['todo', 'in_progress']).count()
        
        snapshot = WeeklyAnalyticsSnapshot.objects.create(
            wedding=wedding,
            week_number=week_number,
            confirmed_count=confirmed,
            pending_count=pending,
            spending_to_date=Decimal(str(spending)),
            tasks_completed=tasks_completed,
            tasks_pending=tasks_pending
        )
        
        return snapshot
    
    @staticmethod
    def calculate_engagement_metrics(wedding):
        """Calculate guest engagement metrics"""
        guests = wedding.guests.all()
        
        # RSVP Response rate
        responded = guests.exclude(rsvp_status='pending').count()
        response_rate = (responded / guests.count() * 100) if guests.count() > 0 else 0
        
        # Relationship breakdown
        relationship_breakdown = {}
        for rel in ['family', 'friend', 'colleague', 'other']:
            count = guests.filter(relationship=rel).count()
            relationship_breakdown[rel] = count
        
        # Dietary requirements
        dietary_count = guests.exclude(dietary_restrictions='').count()
        dietary_percentage = (dietary_count / guests.count() * 100) if guests.count() > 0 else 0
        
        # Group size distribution
        group_distribution = {}
        for guest in guests:
            size = guest.number_of_guests
            if size not in group_distribution:
                group_distribution[size] = 0
            group_distribution[size] += 1
        
        metrics, created = GuestEngagementMetrics.objects.get_or_create(wedding=wedding)
        metrics.rsvp_response_rate = response_rate
        metrics.relationship_breakdown = relationship_breakdown
        metrics.dietary_requirements_percentage = dietary_percentage
        metrics.group_size_distribution = group_distribution
        metrics.save()
        
        return metrics
    
    @staticmethod
    def get_comparison_data(wedding):
        """Get data comparing actual vs estimated"""
        return {
            'budget': {
                'estimated': float(wedding.analytics.total_estimated_budget),
                'actual': float(wedding.analytics.total_actual_spending),
                'variance': float(wedding.analytics.budget_variance)
            },
            'guests': {
                'invited': wedding.analytics.total_invitations_sent,
                'confirmed': wedding.analytics.total_confirmed,
                'pending': wedding.analytics.total_pending,
                'declined': wedding.analytics.total_declined
            },
            'tasks': {
                'total': wedding.analytics.total_tasks,
                'completed': wedding.analytics.completed_tasks,
                'pending': wedding.analytics.pending_tasks,
                'overdue': wedding.analytics.overdue_tasks,
                'completion_percentage': wedding.analytics.completion_percentage
            }
        }