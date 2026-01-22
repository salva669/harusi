import { useState, useEffect } from 'react';
import { pledgeAPI, guestAPI } from '../../services/api';

export const PledgeForm = ({ weddingId, pledge, onSave, onCancel }) => {
  const [guests, setGuests] = useState([]);
  const [formData, setFormData] = useState({
    guest: '',
    pledged_amount: '',
    paid_amount: 0,
    payment_method: '',
    payment_deadline: '',
    notes: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    loadGuests();
    if (pledge) {
      setFormData({
        guest: pledge.guest || '',
        pledged_amount: pledge.pledged_amount || '',
        paid_amount: pledge.paid_amount || 0,
        payment_method: pledge.payment_method || '',
        payment_deadline: pledge.payment_deadline || '',
        notes: pledge.notes || '',
      });
    }
  }, [pledge]);

  const loadGuests = async () => {
    try {
      const response = await guestAPI.getAll(weddingId);
      setGuests(response.data);
    } catch (err) {
      console.error('Failed to load guests');
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      // Prepare data - remove empty strings for optional fields
      const dataToSubmit = {
        guest: parseInt(formData.guest),
        pledged_amount: parseFloat(formData.pledged_amount),
        paid_amount: parseFloat(formData.paid_amount) || 0,
        payment_method: formData.payment_method || null,
        payment_deadline: formData.payment_deadline || null,
        notes: formData.notes || '',
      };

      console.log('Submitting data:', dataToSubmit); // Debug log

      if (pledge) {
        await pledgeAPI.update(weddingId, pledge.id, dataToSubmit);
      } else {
        await pledgeAPI.create(weddingId, dataToSubmit);
      }
      onSave();
    } catch (err) {
      console.error('Full error:', err);
      console.error('Error response:', err.response?.data);
      setError(err.response?.data?.detail || 'Failed to save pledge');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="card pledge-form">
      <h3>{pledge ? 'Edit Pledge' : 'Record New Pledge'}</h3>

      {error && <div className="alert error">{error}</div>}

      <div className="form-row">
        <div className="form-group">
          <label>Guest *</label>
          <select name="guest" value={formData.guest} onChange={handleChange} required>
            <option value="">Select Guest</option>
            {guests.map(g => (
              <option key={g.id} value={g.id}>{g.name}</option>
            ))}
          </select>
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Pledged Amount (TZS) *</label>
          <input
            type="number"
            name="pledged_amount"
            value={formData.pledged_amount}
            onChange={handleChange}
            required
            min="0"
            step="1000"
          />
        </div>
        <div className="form-group">
          <label>Initial Payment (TZS)</label>
          <input
            type="number"
            name="paid_amount"
            value={formData.paid_amount}
            onChange={handleChange}
            min="0"
            step="1000"
          />
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Payment Method</label>
          <select name="payment_method" value={formData.payment_method} onChange={handleChange}>
            <option value="">Select Method</option>
            <option value="cash">Cash</option>
            <option value="mobile_money">Mobile Money (M-Pesa/TigoPesa)</option>
            <option value="bank_transfer">Bank Transfer</option>
            <option value="cheque">Cheque</option>
            <option value="other">Other</option>
          </select>
        </div>
        <div className="form-group">
          <label>Payment Deadline</label>
          <input
            type="date"
            name="payment_deadline"
            value={formData.payment_deadline}
            onChange={handleChange}
          />
        </div>
      </div>

      <div className="form-group">
        <label>Notes</label>
        <textarea
          name="notes"
          value={formData.notes}
          onChange={handleChange}
          rows="3"
          placeholder="Add any additional information..."
        />
      </div>

      <div className="form-actions">
        <button type="submit" className="primary" disabled={loading}>
          {loading ? 'Saving...' : 'Save Pledge'}
        </button>
        <button type="button" className="secondary" onClick={onCancel}>
          Cancel
        </button>
      </div>
    </form>
  );
};