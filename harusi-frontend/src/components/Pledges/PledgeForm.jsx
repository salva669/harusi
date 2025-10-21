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

  useEffect(() => {
    loadGuests();
    if (pledge) {
      setFormData(pledge);
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

    try {
      if (pledge) {
        await pledgeAPI.update(weddingId, pledge.id, formData);
      } else {
        await pledgeAPI.create(weddingId, formData);
      }
      onSave();
    } catch (err) {
      console.error('Failed to save pledge');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="card pledge-form">
      <h3>{pledge ? 'Edit Pledge' : 'Record New Pledge'}</h3>

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