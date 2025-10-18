import { useState, useEffect } from 'react';
import { budgetAPI } from '../../services/api';
import './Budget.css';

export const BudgetForm = ({ weddingId, item, onSave, onCancel }) => {
  const [formData, setFormData] = useState({
    category: 'other',
    item_name: '',
    estimated_cost: '',
    actual_cost: '',
    notes: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const categories = [
    'venue', 'catering', 'decoration', 'photography', 
    'music', 'transportation', 'accommodation', 'attire', 
    'invitation', 'other'
  ];

  useEffect(() => {
    if (item) {
      setFormData(item);
    }
  }, [item]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      if (item) {
        await budgetAPI.update(weddingId, item.id, formData);
      } else {
        await budgetAPI.create(weddingId, formData);
      }
      onSave();
    } catch (err) {
      setError('Failed to save budget item');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="card budget-form">
      <h3>{item ? 'Edit Budget Item' : 'Add Budget Item'}</h3>
      
      {error && <div className="alert error">{error}</div>}

      <div className="form-row">
        <div className="form-group">
          <label>Category *</label>
          <select name="category" value={formData.category} onChange={handleChange} required>
            {categories.map(cat => (
              <option key={cat} value={cat}>
                {cat.charAt(0).toUpperCase() + cat.slice(1)}
              </option>
            ))}
          </select>
        </div>
        <div className="form-group">
          <label>Item Name *</label>
          <input
            type="text"
            name="item_name"
            value={formData.item_name}
            onChange={handleChange}
            required
            placeholder="e.g., Venue Rental"
          />
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Estimated Cost (TZS) *</label>
          <input
            type="number"
            name="estimated_cost"
            value={formData.estimated_cost}
            onChange={handleChange}
            required
            step="1000"
          />
        </div>
        <div className="form-group">
          <label>Actual Cost (TZS)</label>
          <input
            type="number"
            name="actual_cost"
            value={formData.actual_cost}
            onChange={handleChange}
            step="1000"
            placeholder="Leave blank if not yet paid"
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
          placeholder="Add any additional notes..."
        />
      </div>

      <div className="form-actions">
        <button type="submit" className="primary" disabled={loading}>
          {loading ? 'Saving...' : 'Save Item'}
        </button>
        <button type="button" className="secondary" onClick={onCancel}>
          Cancel
        </button>
      </div>
    </form>
  );
};