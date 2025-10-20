from django.core.mail import send_mail, EmailMultiAlternatives
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.conf import settings
from django.utils import timezone
from datetime import timedelta

class WeddingEmailService:
    @staticmethod
    def send_rsvp_reminder(guest):
        """Send RSVP reminder to guest"""
        if guest.rsvp_status != 'pending':
            return False
        
        subject = f"RSVP Reminder for {guest.wedding.bride_name} & {guest.wedding.groom_name}'s Wedding"
        
        context = {
            'guest_name': guest.name,
            'bride_name': guest.wedding.bride_name,
            'groom_name': guest.wedding.groom_name,
            'wedding_date': guest.wedding.wedding_date,
            'venue': guest.wedding.venue,
        }
        
        html_message = render_to_string('email/rsvp_reminder.html', context)
        plain_message = strip_tags(html_message)
        
        if guest.email:
            send_mail(
                subject,
                plain_message,
                settings.DEFAULT_FROM_EMAIL,
                [guest.email],
                html_message=html_message,
                fail_silently=False,
            )
            return True
        return False
    
    @staticmethod
    def send_task_reminder(task):
        """Send task reminder to assigned person"""
        if not task.assigned_to or not task.due_date:
            return False
        
        subject = f"Task Reminder: {task.title}"
        context = {
            'task_title': task.title,
            'task_description': task.description,
            'due_date': task.due_date,
            'wedding': task.wedding,
        }
        
        html_message = render_to_string('email/task_reminder.html', context)
        plain_message = strip_tags(html_message)
        
        # Send to task creator or user
        send_mail(
            subject,
            plain_message,
            settings.DEFAULT_FROM_EMAIL,
            [task.wedding.user.email],
            html_message=html_message,
            fail_silently=False,
        )
        return True
    
    @staticmethod
    def send_invitation_email(guest, invitation_template):
        """Send wedding invitation to guest"""
        subject = f"You're Invited! {invitation_template.wedding.bride_name} & {invitation_template.wedding.groom_name}"
        
        context = {
            'guest_name': guest.name,
            'title': invitation_template.title,
            'description': invitation_template.description,
            'ceremony_time': invitation_template.ceremony_time,
            'ceremony_location': invitation_template.ceremony_location,
            'reception_time': invitation_template.reception_time,
            'reception_location': invitation_template.reception_location,
            'dress_code': invitation_template.dress_code,
            'rsvp_deadline': invitation_template.rsvp_deadline,
            'rsvp_email': invitation_template.rsvp_email,
            'custom_message': invitation_template.custom_message,
        }
        
        html_message = render_to_string('email/invitation.html', context)
        plain_message = strip_tags(html_message)
        
        if guest.email:
            send_mail(
                subject,
                plain_message,
                settings.DEFAULT_FROM_EMAIL,
                [guest.email],
                html_message=html_message,
                fail_silently=False,
            )
            return True
        return False
    
    @staticmethod
    def send_vendor_reminder(vendor):
        """Send reminder to vendor"""
        subject = f"Reminder: {vendor.business_name} - {vendor.wedding} Wedding"
        
        context = {
            'vendor_name': vendor.contact_person,
            'business_name': vendor.business_name,
            'wedding_date': vendor.wedding.wedding_date,
            'wedding_couple': f"{vendor.wedding.bride_name} & {vendor.wedding.groom_name}",
        }
        
        html_message = render_to_string('email/vendor_reminder.html', context)
        plain_message = strip_tags(html_message)
        
        send_mail(
            subject,
            plain_message,
            settings.DEFAULT_FROM_EMAIL,
            [vendor.email],
            html_message=html_message,
            fail_silently=False,
        )
        return True
    
    @staticmethod
    def send_wedding_countdown(wedding):
        """Send countdown email"""
        days_until = (wedding.wedding_date - timezone.now().date()).days
        
        subject = f"Only {days_until} Days Until Your Wedding! 🎉"
        
        context = {
            'days_until': days_until,
            'couple': f"{wedding.bride_name} & {wedding.groom_name}",
            'wedding_date': wedding.wedding_date,
        }
        
        html_message = render_to_string('email/countdown.html', context)
        plain_message = strip_tags(html_message)
        
        send_mail(
            subject,
            plain_message,
            settings.DEFAULT_FROM_EMAIL,
            [wedding.user.email],
            html_message=html_message,
            fail_silently=False,
        )
        return True