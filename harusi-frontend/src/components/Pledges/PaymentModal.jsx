import { useState } from 'react';
import { pledgeAPI } from '../../services/api';
import { Modal } from '../Common/Modal';

export const PaymentModal = ({ pledge, weddingId, onClose, onSuccess }) => {
  const [formData, setFormData] = useState({
    amount: '',
    payment_date: new Date().toISOString().split('T')[0],
    payment_method: pledge.payment_method || '',
    reference_number: '',
    notes: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const remainingBalance = pledge.balance;

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    // Validate amount
    const paymentAmount = parseFloat(formData.amount);
    if (paymentAmount <= 0) {
      setError('Payment amount must be greater than 0');
      setLoading(false);
      return;
    }

    if (paymentAmount > remainingBalance) {
      setError(`Payment amount cannot exceed remaining balance of TZS ${remainingBalance.toLocaleString()}`);
      setLoading(false);
      return;
    }

    try {
      const dataToSubmit = {
        amount: paymentAmount,
        payment_date: formData.payment_date,
        payment_method: formData.payment_method,
        reference_number: formData.reference_number || '',
        notes: formData.notes || '',
      };

      console.log('Submitting payment:', dataToSubmit);

      await pledgeAPI.recordPayment(weddingId, pledge.id, dataToSubmit);
      onSuccess();
    } catch (err) {
      console.error('Full error:', err);
      console.error('Error response:', err.response?.data);
      setError(err.response?.data?.detail || err.response?.data?.error || 'Failed to record payment');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Modal
      isOpen={true}
      onClose={onClose}
      title="Record Payment"
    >
      <div className="payment-modal-info">
        <div className="info-row">
          <span className="label">Guest:</span>
          <span className="value">{pledge.guest_name}</span>
        </div>
        <div className="info-row">
          <span className="label">Total Pledged:</span>
          <span className="value">TZS {pledge.pledged_amount.toLocaleString()}</span>
        </div>
        <div className="info-row">
          <span className="label">Already Paid:</span>
          <span className="value">TZS {pledge.paid_amount.toLocaleString()}</span>
        </div>
        <div className="info-row highlight">
          <span className="label">Remaining Balance:</span>
          <span className="value">TZS {remainingBalance.toLocaleString()}</span>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="payment-form">
        {error && <div className="alert error">{error}</div>}

        <div className="form-group">
          <label>Payment Amount (TZS) *</label>
          <input
            type="number"
            name="amount"
            value={formData.amount}
            onChange={handleChange}
            required
            min="1"
            max={remainingBalance}
            step="1"
            placeholder={`Max: ${remainingBalance.toLocaleString()}`}
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
            max={new Date().toISOString().split('T')[0]}
          />
        </div>

        <div className="form-group">
          <label>Payment Method *</label>
          <select 
            name="payment_method" 
            value={formData.payment_method} 
            onChange={handleChange}
            required
          >
            <option value="">Select Method</option>
            <option value="cash">Cash</option>
            <option value="mobile_money">Mobile Money (M-Pesa/TigoPesa)</option>
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
            placeholder="Transaction ID, Receipt No, etc."
          />
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
            {loading ? 'Recording...' : 'Record Payment'}
          </button>
          <button type="button" className="secondary" onClick={onClose}>
            Cancel
          </button>
        </div>
      </form>
    </Modal>
  );
};