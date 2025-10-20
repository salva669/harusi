from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image, PageBreak
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT
from io import BytesIO
from datetime import datetime

class WeddingPDFGenerator:
    @staticmethod
    def generate_guest_list_pdf(wedding):
        """Generate guest list PDF"""
        buffer = BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter)
        elements = []
        styles = getSampleStyleSheet()
        
        # Title
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=24,
            textColor=colors.HexColor('#667eea'),
            spaceAfter=30,
            alignment=TA_CENTER
        )
        
        title = Paragraph(
            f"{wedding.bride_name} & {wedding.groom_name}<br/>Guest List",
            title_style
        )
        elements.append(title)
        elements.append(Spacer(1, 0.2*inch))
        
        # Wedding Details
        details = f"""
        <b>Wedding Date:</b> {wedding.wedding_date.strftime('%B %d, %Y')}<br/>
        <b>Venue:</b> {wedding.venue}<br/>
        <b>Generated:</b> {datetime.now().strftime('%B %d, %Y %I:%M %p')}
        """
        elements.append(Paragraph(details, styles['Normal']))
        elements.append(Spacer(1, 0.3*inch))
        
        # Guest Table
        guests = wedding.guests.all()
        data = [['No.', 'Guest Name', 'Relationship', 'RSVP Status', 'Guests', 'Contact']]
        
        for i, guest in enumerate(guests, 1):
            data.append([
                str(i),
                guest.name,
                guest.get_relationship_display(),
                guest.rsvp_status.upper(),
                str(guest.number_of_guests),
                guest.email or guest.phone or 'N/A'
            ])
        
        table = Table(data, colWidths=[0.5*inch, 1.5*inch, 1.2*inch, 1*inch, 0.7*inch, 1.5*inch])
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#667eea')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
            ('GRID', (0, 0), (-1, -1), 1, colors.black),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.lightgrey]),
        ]))
        
        elements.append(table)
        elements.append(Spacer(1, 0.3*inch))
        
        # Summary
        confirmed = wedding.guests.filter(rsvp_status='confirmed').count()
        pending = wedding.guests.filter(rsvp_status='pending').count()
        declined = wedding.guests.filter(rsvp_status='declined').count()
        total_guests = sum([g.number_of_guests for g in wedding.guests.all()])
        
        summary = f"""
        <b>Summary:</b><br/>
        Total Invitations: {guests.count()}<br/>
        Confirmed: {confirmed} | Pending: {pending} | Declined: {declined}<br/>
        Total Guest Count (with +1s): {total_guests}
        """
        elements.append(Paragraph(summary, styles['Normal']))
        
        doc.build(elements)
        buffer.seek(0)
        return buffer
    
    @staticmethod
    def generate_budget_report_pdf(wedding):
        """Generate budget report PDF"""
        buffer = BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter)
        elements = []
        styles = getSampleStyleSheet()
        
        # Title
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=24,
            textColor=colors.HexColor('#667eea'),
            spaceAfter=30,
            alignment=TA_CENTER
        )
        
        title = Paragraph(
            f"{wedding.bride_name} & {wedding.groom_name}<br/>Budget Report",
            title_style
        )
        elements.append(title)
        elements.append(Spacer(1, 0.2*inch))
        
        budget_items = wedding.budget_items.all()
        total_estimated = sum([float(item.estimated_cost) for item in budget_items])
        total_actual = sum([float(item.actual_cost or 0) for item in budget_items])
        remaining = total_estimated - total_actual
        
        # Summary Cards
        summary = f"""
        <b>Total Budget:</b> TZS {total_estimated:,.0f}<br/>
        <b>Total Spent:</b> TZS {total_actual:,.0f}<br/>
        <b>Remaining:</b> TZS {remaining:,.0f}<br/>
        <b>Percentage Spent:</b> {(total_actual/total_estimated*100 if total_estimated > 0 else 0):.1f}%
        """
        elements.append(Paragraph(summary, styles['Normal']))
        elements.append(Spacer(1, 0.3*inch))
        
        # Category breakdown
        categories = {}
        for item in budget_items:
            if item.category not in categories:
                categories[item.category] = {'estimated': 0, 'actual': 0}
            categories[item.category]['estimated'] += float(item.estimated_cost)
            categories[item.category]['actual'] += float(item.actual_cost or 0)
        
        # Category table
        cat_data = [['Category', 'Estimated', 'Actual', 'Difference']]
        for cat, amounts in sorted(categories.items()):
            diff = amounts['estimated'] - amounts['actual']
            cat_data.append([
                cat.replace('_', ' ').title(),
                f"TZS {amounts['estimated']:,.0f}",
                f"TZS {amounts['actual']:,.0f}",
                f"TZS {diff:,.0f}"
            ])
        
        cat_table = Table(cat_data, colWidths=[2*inch, 1.5*inch, 1.5*inch, 1.5*inch])
        cat_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#667eea')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'RIGHT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('GRID', (0, 0), (-1, -1), 1, colors.black),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.lightgrey]),
        ]))
        
        elements.append(cat_table)
        
        doc.build(elements)
        buffer.seek(0)
        return buffer
    
    @staticmethod
    def generate_timeline_pdf(wedding):
        """Generate wedding timeline PDF"""
        buffer = BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter)
        elements = []
        styles = getSampleStyleSheet()
        
        # Title
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=24,
            textColor=colors.HexColor('#667eea'),
            spaceAfter=30,
            alignment=TA_CENTER
        )
        
        title = Paragraph(
            f"{wedding.bride_name} & {wedding.groom_name}<br/>Wedding Timeline",
            title_style
        )
        elements.append(title)
        elements.append(Spacer(1, 0.2*inch))
        
        # Timeline events
        events = wedding.timeline_events.all().order_by('date')
        
        for event in events:
            status = "✓ COMPLETED" if event.is_completed else "○ PENDING"
            event_text = f"""
            <b>{event.get_event_type_display()}</b> - {event.date.strftime('%B %d, %Y')} {status}<br/>
            <b>{event.title}</b><br/>
            {event.description or 'No description'}<br/>
            {f"<b>Location:</b> {event.location}<br/>" if event.location else ""}
            {f"<b>Time:</b> {event.time.strftime('%I:%M %p')}<br/>" if event.time else ""}
            """
            elements.append(Paragraph(event_text, styles['Normal']))
            elements.append(Spacer(1, 0.2*inch))
        
        doc.build(elements)
        buffer.seek(0)
        return buffer
    
    @staticmethod
    def generate_vendor_list_pdf(wedding):
        """Generate vendor list PDF"""
        buffer = BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter)
        elements = []
        styles = getSampleStyleSheet()
        
        # Title
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=24,
            textColor=colors.HexColor('#667eea'),
            spaceAfter=30,
            alignment=TA_CENTER
        )
        
        title = Paragraph(
            f"{wedding.bride_name} & {wedding.groom_name}<br/>Vendor List",
            title_style
        )
        elements.append(title)
        elements.append(Spacer(1, 0.2*inch))
        
        # Vendors by category
        vendors = wedding.vendors.all()
        categories = {}
        for vendor in vendors:
            cat = vendor.get_vendor_type_display()
            if cat not in categories:
                categories[cat] = []
            categories[cat].append(vendor)
        
        for category in sorted(categories.keys()):
            elements.append(Paragraph(f"<b>{category}</b>", styles['Heading2']))
            elements.append(Spacer(1, 0.1*inch))
            
            for vendor in categories[category]:
                vendor_text = f"""
                <b>{vendor.business_name}</b> - Status: {vendor.get_status_display()}<br/>
                Contact: {vendor.contact_person}<br/>
                Phone: {vendor.phone} | Email: {vendor.email}<br/>
                Quote: TZS {vendor.quote:,.0f if vendor.quote else 'N/A'}<br/>
                {f"Deposit Paid: TZS {vendor.deposit_paid:,.0f}<br/>" if vendor.deposit_paid else ""}
                {f"Final Amount: TZS {vendor.final_amount:,.0f}<br/>" if vendor.final_amount else ""}
                {f"Notes: {vendor.notes}<br/>" if vendor.notes else ""}
                """
                elements.append(Paragraph(vendor_text, styles['Normal']))
                elements.append(Spacer(1, 0.15*inch))
        
        doc.build(elements)
        buffer.seek(0)
        return buffer
    
    @staticmethod
    def generate_invitation_card_pdf(invitation_template, guest=None):
        """Generate fancy invitation card PDF"""
        buffer = BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter, topMargin=0.5*inch, bottomMargin=0.5*inch)
        elements = []
        styles = getSampleStyleSheet()
        
        # Fancy title style
        title_style = ParagraphStyle(
            'InviteTitle',
            parent=styles['Heading1'],
            fontSize=36,
            textColor=colors.HexColor('#764ba2'),
            spaceAfter=20,
            alignment=TA_CENTER,
            fontName='Helvetica-Bold'
        )
        
        # Main title
        elements.append(Spacer(1, 0.5*inch))
        elements.append(Paragraph("Together with their parents<br/>request the honor of your presence<br/>at the marriage of", 
                                 ParagraphStyle('Normal', parent=styles['Normal'], alignment=TA_CENTER)))
        elements.append(Spacer(1, 0.2*inch))
        
        elements.append(Paragraph(invitation_template.title, title_style))
        elements.append(Spacer(1, 0.3*inch))
        
        # Details
        details_style = ParagraphStyle('Details', parent=styles['Normal'], alignment=TA_CENTER, fontSize=12)
        
        if invitation_template.ceremony_time and invitation_template.ceremony_location:
            ceremony = f"<b>Ceremony</b><br/>{invitation_template.ceremony_time.strftime('%I:%M %p')}<br/>{invitation_template.ceremony_location}"
            elements.append(Paragraph(ceremony, details_style))
            elements.append(Spacer(1, 0.2*inch))
        
        if invitation_template.reception_time and invitation_template.reception_location:
            reception = f"<b>Reception</b><br/>{invitation_template.reception_time.strftime('%I:%M %p')}<br/>{invitation_template.reception_location}"
            elements.append(Paragraph(reception, details_style))
            elements.append(Spacer(1, 0.2*inch))
        
        if invitation_template.dress_code:
            elements.append(Paragraph(f"<b>Dress Code:</b> {invitation_template.dress_code}", details_style))
            elements.append(Spacer(1, 0.2*inch))
        
        if invitation_template.rsvp_deadline:
            rsvp = f"<b>RSVP by {invitation_template.rsvp_deadline.strftime('%B %d, %Y')}</b><br/>{invitation_template.rsvp_email}"
            elements.append(Paragraph(rsvp, details_style))
        
        if invitation_template.custom_message:
            elements.append(Spacer(1, 0.2*inch))
            elements.append(Paragraph(invitation_template.custom_message, ParagraphStyle('Message', parent=styles['Normal'], alignment=TA_CENTER)))
        
        doc.build(elements)
        buffer.seek(0)
        return buffer