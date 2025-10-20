from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator

# Create your models here.
class Wedding(models.Model):
    STATUS_CHOICES = [
        ('planning', 'Planning'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='weddings')
    bride_name = models.CharField(max_length=100)
    groom_name = models.CharField(max_length=100)
    wedding_date = models.DateField()
    venue = models.CharField(max_length=255)
    budget = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0)])
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='planning')
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-wedding_date']
    
    def __str__(self):
        return f"{self.bride_name} & {self.groom_name} - {self.wedding_date}"

class Guest(models.Model):
    RELATIONSHIP_CHOICES = [
        ('family', 'Family'),
        ('friend', 'Friend'),
        ('colleague', 'Colleague'),
        ('other', 'Other'),
    ]
    
    RSVP_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('declined', 'Declined'),
    ]
    
    wedding = models.ForeignKey(Wedding, on_delete=models.CASCADE, related_name='guests')
    name = models.CharField(max_length=100)
    phone = models.CharField(max_length=20, blank=True)
    email = models.EmailField(blank=True)
    relationship = models.CharField(max_length=20, choices=RELATIONSHIP_CHOICES)
    rsvp_status = models.CharField(max_length=20, choices=RSVP_CHOICES, default='pending')
    number_of_guests = models.IntegerField(default=1, validators=[MinValueValidator(1)])
    dietary_restrictions = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.name} - {self.wedding}"


class Task(models.Model):
    PRIORITY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('urgent', 'Urgent'),
    ]
    
    STATUS_CHOICES = [
        ('todo', 'To Do'),
        ('in_progress', 'In Progress'),
        ('done', 'Done'),
    ]
    
    wedding = models.ForeignKey(Wedding, on_delete=models.CASCADE, related_name='tasks')
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    priority = models.CharField(max_length=10, choices=PRIORITY_CHOICES, default='medium')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='todo')
    due_date = models.DateField(null=True, blank=True)
    assigned_to = models.CharField(max_length=100, blank=True)
    cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-priority', 'due_date']
    
    def __str__(self):
        return f"{self.title} - {self.wedding}"


class Budget(models.Model):
    CATEGORY_CHOICES = [
        ('venue', 'Venue'),
        ('catering', 'Catering'),
        ('decoration', 'Decoration'),
        ('photography', 'Photography'),
        ('music', 'Music'),
        ('transportation', 'Transportation'),
        ('accommodation', 'Accommodation'),
        ('attire', 'Attire'),
        ('invitation', 'Invitation'),
        ('other', 'Other'),
    ]
    
    wedding = models.ForeignKey(Wedding, on_delete=models.CASCADE, related_name='budget_items')
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    item_name = models.CharField(max_length=200)
    estimated_cost = models.DecimalField(max_digits=10, decimal_places=2)
    actual_cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.category} - {self.item_name}"

class PhotoGallery(models.Model):
    ALBUM_TYPES = [
        ('pre_wedding', 'Pre-Wedding'),
        ('ceremony', 'Ceremony'),
        ('reception', 'Reception'),
        ('other', 'Other'),
    ]
    
    wedding = models.ForeignKey(Wedding, on_delete=models.CASCADE, related_name='photo_albums')
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    album_type = models.CharField(max_length=50, choices=ALBUM_TYPES)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} - {self.wedding}"


class Photo(models.Model):
    album = models.ForeignKey(PhotoGallery, on_delete=models.CASCADE, related_name='photos')
    image = models.ImageField(upload_to='wedding_photos/%Y/%m/%d/')
    caption = models.CharField(max_length=255, blank=True)
    uploaded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-uploaded_at']
    
    def __str__(self):
        return f"Photo in {self.album.title}"


class Timeline(models.Model):
    EVENT_TYPES = [
        ('save_date', 'Save the Date'),
        ('invitation', 'Send Invitations'),
        ('rsvp_deadline', 'RSVP Deadline'),
        ('final_headcount', 'Final Headcount'),
        ('ceremony_rehearsal', 'Ceremony Rehearsal'),
        ('wedding_day', 'Wedding Day'),
        ('honeymoon', 'Honeymoon'),
        ('thank_you', 'Send Thank You Cards'),
        ('other', 'Other'),
    ]
    
    wedding = models.ForeignKey(Wedding, on_delete=models.CASCADE, related_name='timeline_events')
    event_type = models.CharField(max_length=50, choices=EVENT_TYPES)
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    date = models.DateField()
    time = models.TimeField(null=True, blank=True)
    location = models.CharField(max_length=255, blank=True)
    is_completed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['date']
    
    def __str__(self):
        return f"{self.title} - {self.date}"


class Vendor(models.Model):
    VENDOR_TYPES = [
        ('venue', 'Venue'),
        ('catering', 'Catering'),
        ('photography', 'Photography'),
        ('videography', 'Videography'),
        ('flowers', 'Flowers & Decoration'),
        ('music', 'Music & DJ'),
        ('transportation', 'Transportation'),
        ('accommodation', 'Accommodation'),
        ('invitation', 'Invitation & Stationery'),
        ('makeup', 'Makeup & Hair'),
        ('wedding_planner', 'Wedding Planner'),
        ('other', 'Other'),
    ]
    
    STATUS_CHOICES = [
        ('inquiry', 'Inquiry'),
        ('negotiating', 'Negotiating'),
        ('booked', 'Booked'),
        ('completed', 'Completed'),
        ('rejected', 'Rejected'),
    ]
    
    wedding = models.ForeignKey(Wedding, on_delete=models.CASCADE, related_name='vendors')
    vendor_type = models.CharField(max_length=50, choices=VENDOR_TYPES)
    business_name = models.CharField(max_length=200)
    contact_person = models.CharField(max_length=100)
    phone = models.CharField(max_length=20)
    email = models.EmailField()
    website = models.URLField(blank=True)
    quote = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    deposit_paid = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    final_amount = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='inquiry')
    vendor_notes = models.TextField(blank=True)  # ← CHANGED FROM 'notes' to 'vendor_notes'
    contract_file = models.FileField(upload_to='vendor_contracts/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['vendor_type', 'status']
    
    def __str__(self):
        return f"{self.business_name} ({self.vendor_type})"


class VendorNote(models.Model):
    vendor = models.ForeignKey(Vendor, on_delete=models.CASCADE, related_name='note_entries')
    content = models.TextField()
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']


class InvitationTemplate(models.Model):
    wedding = models.OneToOneField(Wedding, on_delete=models.CASCADE, related_name='invitation_template')
    title = models.CharField(max_length=200)
    description = models.TextField()
    ceremony_time = models.TimeField(null=True, blank=True)
    ceremony_location = models.CharField(max_length=255, blank=True)
    reception_time = models.TimeField(null=True, blank=True)
    reception_location = models.CharField(max_length=255, blank=True)
    dress_code = models.CharField(max_length=100, blank=True)
    rsvp_deadline = models.DateField(null=True, blank=True)
    rsvp_email = models.EmailField()
    custom_message = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Invitation - {self.wedding}"

class WeddingAnalytics(models.Model):
    """Store aggregated analytics data for weddings"""
    wedding = models.OneToOneField(Wedding, on_delete=models.CASCADE, related_name='analytics')
    
    # Guest Analytics
    total_invitations_sent = models.IntegerField(default=0)
    total_confirmed = models.IntegerField(default=0)
    total_pending = models.IntegerField(default=0)
    total_declined = models.IntegerField(default=0)
    average_guests_per_invitation = models.FloatField(default=1.0)
    
    # Budget Analytics
    total_estimated_budget = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total_actual_spending = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    budget_variance = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    budget_category_breakdown = models.JSONField(default=dict)
    
    # Task Analytics
    total_tasks = models.IntegerField(default=0)
    completed_tasks = models.IntegerField(default=0)
    pending_tasks = models.IntegerField(default=0)
    overdue_tasks = models.IntegerField(default=0)
    completion_percentage = models.FloatField(default=0)
    
    # Vendor Analytics
    total_vendors = models.IntegerField(default=0)
    vendors_booked = models.IntegerField(default=0)
    average_vendor_quote = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total_vendor_cost = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    
    # Timeline Analytics
    days_until_wedding = models.IntegerField(default=0)
    weeks_until_wedding = models.IntegerField(default=0)
    completion_by_milestone = models.JSONField(default=dict)
    
    # Performance Metrics
    planning_health_score = models.FloatField(default=0)  # 0-100
    budget_health_score = models.FloatField(default=0)    # 0-100
    task_health_score = models.FloatField(default=0)      # 0-100
    guest_health_score = models.FloatField(default=0)     # 0-100
    overall_health_score = models.FloatField(default=0)   # 0-100
    
    last_updated = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name_plural = "Wedding Analytics"
    
    def __str__(self):
        return f"Analytics - {self.wedding}"


class WeeklyAnalyticsSnapshot(models.Model):
    """Store weekly snapshots for trend analysis"""
    wedding = models.ForeignKey(Wedding, on_delete=models.CASCADE, related_name='weekly_snapshots')
    
    week_number = models.IntegerField()
    confirmed_count = models.IntegerField()
    pending_count = models.IntegerField()
    spending_to_date = models.DecimalField(max_digits=12, decimal_places=2)
    tasks_completed = models.IntegerField()
    tasks_pending = models.IntegerField()
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['week_number']
        verbose_name_plural = "Weekly Analytics Snapshots"
    
    def __str__(self):
        return f"Week {self.week_number} - {self.wedding}"


class GuestEngagementMetrics(models.Model):
    """Track guest engagement patterns"""
    wedding = models.ForeignKey(Wedding, on_delete=models.CASCADE, related_name='engagement_metrics')
    
    rsvp_response_rate = models.FloatField(default=0)  # percentage
    average_response_time = models.IntegerField(default=0)  # days
    relationship_breakdown = models.JSONField(default=dict)  # {family: count, friend: count}
    dietary_requirements_percentage = models.FloatField(default=0)
    group_size_distribution = models.JSONField(default=dict)  # {1: count, 2: count, etc}
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name_plural = "Guest Engagement Metrics"
    
    def __str__(self):
        return f"Engagement - {self.wedding}"