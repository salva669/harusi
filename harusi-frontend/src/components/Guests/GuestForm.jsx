import { useState, useEffect } from 'react';
import { guestAPI } from '../../services/api';
import './Guests.css';

export const GuestForm = ({ weddingId, guest, onSave, onCancel }) => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    relationship: 'friend',
    rsvp_status: 'pending',
    number_of_guests: 1,
    dietary_restrictions: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (guest) {
      setFormData(guest);
    }
  }, [guest]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
  
    try {
      if (guest) {
        await guestAPI.update(weddingId, guest.id, formData);
      } else {
        await guestAPI.create(weddingId, formData);
      }
      onSave();
    } catch (err) {
      console.error('Error details:', err.response?.data);  // ← ADD THIS for debugging
      setError('Failed to save guest');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="card guest-form">
      <h3>{guest ? 'Edit Guest' : 'Add New Guest'}</h3>
      
      {error && <div className="alert error">{error}</div>}

      <div className="form-row">
        <div className="form-group">
          <label>Guest Name *</label>
          <input
            type="text"
            name="name"
            value={formData.name}
            onChange={handleChange}
            required
          />
        </div>
        <div className="form-group">
          <label>Relationship</label>
          <select name="relationship" value={formData.relationship} onChange={handleChange}>
            <option value="family">Family</option>
            <option value="friend">Friend</option>
            <option value="colleague">Colleague</option>
            <option value="other">Other</option>
          </select>
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Email</label>
          <input
            type="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
          />
        </div>
        <div className="form-group">
          <label>Phone</label>
          <input
            type="tel"
            name="phone"
            value={formData.phone}
            onChange={handleChange}
          />
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>RSVP Status</label>
          <select name="rsvp_status" value={formData.rsvp_status} onChange={handleChange}>
            <option value="pending">Pending</option>
            <option value="confirmed">Confirmed</option>
            <option value="declined">Declined</option>
          </select>
        </div>
        <div className="form-group">
          <label>Number of Guests</label>
          <input
            type="number"
            name="number_of_guests"
            value={formData.number_of_guests}
            onChange={handleChange}
            min="1"
          />
        </div>
      </div>

      <div className="form-group">
        <label>Dietary Restrictions</label>
        <input
          type="text"
          name="dietary_restrictions"
          value={formData.dietary_restrictions}
          onChange={handleChange}
          placeholder="e.g., Vegetarian, Halal, Allergies"
        />
      </div>

      <div className="form-actions">
        <button type="submit" className="primary" disabled={loading}>
          {loading ? 'Saving...' : 'Save Guest'}
        </button>
        <button type="button" className="secondary" onClick={onCancel}>
          Cancel
        </button>
      </div>
    </form>
  );
};

