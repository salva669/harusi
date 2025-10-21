import { useState } from 'react';
import { pledgeAPI } from '../../services/api';
import './Pledges.css';

export const PaymentModal = ({ pledge, weddingId, onClose, onSuccess }) => {
  const [formData, setFormData] = useState({
    amount: '',
    payment_date: new Date().toISOString().split('T')[0],
    payment_method: 'mobile_money',
    reference_number: '',
    notes: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validate amount
    const amount = parseFloat(formData.amount);
    if (amount > pledge.balance) {
      setError(`Amount cannot exceed balance of TZS ${pledge.balance.toLocaleString()}`);
      return;
    }
    
    setLoading(true);
    setError('');

    try {
      await pledgeAPI.recordPayment(weddingId, pledge.id, {
        ...formData,
        amount: parseFloat(formData.amount)
      });
      onSuccess();
    } catch (err) {
      setError('Failed to record payment');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h3>Record Payment</h3>
          <button className="modal-close" onClick={onClose}>✕</button>
        </div>

        <div className="modal-body">
          <div className="payment-info">
            <p><strong>Guest:</strong> {pledge.guest_name}</p>
            <p><strong>Total Pledged:</strong> TZS {pledge.pledged_amount.toLocaleString()}</p>
            <p><strong>Already Paid:</strong> TZS {pledge.paid_amount.toLocaleString()}</p>
            <p><strong>Balance:</strong> <span className="balance-highlight">TZS {pledge.balance.toLocaleString()}</span></p>
          </div>

          {error && <div className="alert error">{error}</div>}

          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label>Payment Amount (TZS) *</label>
              <input
                type="number"
                name="amount"
                value={formData.amount}
                onChange={handleChange}
                required
                step="100"
                max={pledge.balance}
                placeholder={`Max: ${pledge.balance}`}
              />
            </div>

            <div className="form-group">
              <label>Payment Date *</label>
              <input
                type="date"
                name="payment_date"
                value={formData.payment_date}
                onChange={handleChange}
                required
              />
            </div>

            <div className="form-group">
              <label>Payment Method *</label>
              <select name="payment_method" value={formData.payment_method} onChange={handleChange} required>
                <option value="cash">Cash</option>
                <option value="mobile_money">Mobile Money (M-Pesa/TigoPesa/Airtel)</option>
                <option value="bank_transfer">Bank Transfer</option>
                <option value="cheque">Cheque</option>
                <option value="other">Other</option>
              </select>
            </div>

            <div className="form-group">
              <label>Reference Number</label>
              <input
                type="text"
                name="reference_number"
                value={formData.reference_number}
                onChange={handleChange}
                placeholder="Transaction ID, Receipt No, etc"
              />
            </div>

            <div className="form-group">
              <label>Notes</label>
              <textarea
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                rows="3"
                placeholder="Any additional notes..."
              />
            </div>

            <div className="form-actions">
              <button type="submit" className="primary" disabled={loading}>
                {loading ? 'Recording...' : 'Record Payment'}
              </button>
              <button type="button" className="secondary" onClick={onClose}>
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};