import { useState, useEffect } from 'react';
import { vendorAPI } from '../../services/api';
import './Vendors.css';

export const VendorForm = ({ weddingId, vendor, onSave, onCancel }) => {
  const [formData, setFormData] = useState({
    vendor_type: 'other',
    business_name: '',
    contact_person: '',
    phone: '',
    email: '',
    website: '',
    quote: '',
    deposit_paid: '',
    final_amount: '',
    status: 'inquiry',
    vendor_notes: '',
  });
  const [loading, setLoading] = useState(false);

  const vendorTypes = [
    'venue', 'catering', 'photography', 'videography', 'flowers',
    'music', 'transportation', 'accommodation', 'invitation', 'makeup',
    'wedding_planner', 'other'
  ];

  useEffect(() => {
    if (vendor) {
      setFormData(vendor);
    }
  }, [vendor]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      if (vendor) {
        await vendorAPI.update(weddingId, vendor.id, formData);
      } else {
        await vendorAPI.create(weddingId, formData);
      }
      onSave();
    } catch (err) {
      console.error('Failed to save vendor');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="card vendor-form">
      <h3>{vendor ? 'Edit Vendor' : 'Add New Vendor'}</h3>

      <div className="form-row">
        <div className="form-group">
          <label>Vendor Type *</label>
          <select name="vendor_type" value={formData.vendor_type} onChange={handleChange} required>
            {vendorTypes.map(type => (
              <option key={type} value={type}>
                {type.replace('_', ' ').toUpperCase()}
              </option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label>Business Name *</label>
          <input
            type="text"
            name="business_name"
            value={formData.business_name}
            onChange={handleChange}
            required
          />
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Contact Person *</label>
          <input
            type="text"
            name="contact_person"
            value={formData.contact_person}
            onChange={handleChange}
            required
          />
        </div>
        <div className="form-group">
          <label>Phone *</label>
          <input
            type="tel"
            name="phone"
            value={formData.phone}
            onChange={handleChange}
            required
          />
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Email *</label>
          <input
            type="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            required
          />
        </div>
        <div className="form-group">
          <label>Website</label>
          <input
            type="url"
            name="website"
            value={formData.website}
            onChange={handleChange}
          />
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Quote (TZS)</label>
          <input
            type="number"
            name="quote"
            value={formData.quote}
            onChange={handleChange}
            step="1000"
          />
        </div>
        <div className="form-group">
          <label>Deposit Paid (TZS)</label>
          <input
            type="number"
            name="deposit_paid"
            value={formData.deposit_paid}
            onChange={handleChange}
            step="1000"
          />
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Final Amount (TZS)</label>
          <input
            type="number"
            name="final_amount"
            value={formData.final_amount}
            onChange={handleChange}
            step="1000"
          />
        </div>
        <div className="form-group">
          <label>Status</label>
          <select name="status" value={formData.status} onChange={handleChange}>
            <option value="inquiry">Inquiry</option>
            <option value="negotiating">Negotiating</option>
            <option value="booked">Booked</option>
            <option value="completed">Completed</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>
      </div>

      <div className="form-group">
        <label>Notes</label>
        <textarea
            name="vendor_notes"  
            value={formData.vendor_notes}
            onChange={handleChange}
            rows="3"
            placeholder="Add any notes about this vendor..."
        />
        </div>

      <div className="form-actions">
        <button type="submit" className="primary" disabled={loading}>
          {loading ? 'Saving...' : 'Save Vendor'}
        </button>
        <button type="button" className="secondary" onClick={onCancel}>
          Cancel
        </button>
      </div>
    </form>
  );
};