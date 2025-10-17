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