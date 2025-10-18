import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { weddingAPI } from '../../services/api';
import { Loading } from '../Common/Loading';
import './Wedding.css';

export const WeddingForm = () => {
  const [formData, setFormData] = useState({
    bride_name: '',
    groom_name: '',
    wedding_date: '',
    venue: '',
    budget: '',
    status: 'planning',
    description: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();
  const { id } = useParams();
  const isEdit = !!id;

  useEffect(() => {
    if (isEdit) {
      loadWedding();
    }
  }, [id]);

  const loadWedding = async () => {
    try {
      const response = await weddingAPI.getOne(id);
      setFormData(response.data);
    } catch (err) {
      setError('Failed to load wedding');
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
      if (isEdit) {
        await weddingAPI.update(id, formData);
      } else {
        await weddingAPI.create(formData);
      }
      navigate('/');
    } catch (err) {
      setError('Failed to save wedding');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container">
      <div className="form-container">
        <h1>{isEdit ? 'Edit Wedding' : 'Plan Your Wedding'}</h1>
        
        {error && <div className="alert error">{error}</div>}
        
        <form onSubmit={handleSubmit} className="wedding-form">
          <div className="form-row">
            <div className="form-group">
              <label>Bride's Name *</label>
              <input
                type="text"
                name="bride_name"
                value={formData.bride_name}
                onChange={handleChange}
                required
              />
            </div>
            <div className="form-group">
              <label>Groom's Name *</label>
              <input
                type="text"
                name="groom_name"
                value={formData.groom_name}
                onChange={handleChange}
                required
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Wedding Date *</label>
              <input
                type="date"
                name="wedding_date"
                value={formData.wedding_date}
                onChange={handleChange}
                required
              />
            </div>
            <div className="form-group">
              <label>Budget (TZS) *</label>
              <input
                type="number"
                name="budget"
                value={formData.budget}
                onChange={handleChange}
                required
                step="1000"
              />
            </div>
          </div>

          <div className="form-group">
            <label>Venue *</label>
            <input
              type="text"
              name="venue"
              value={formData.venue}
              onChange={handleChange}
              required
              placeholder="e.g., Dar es Salaam Hotel"
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Status</label>
              <select name="status" value={formData.status} onChange={handleChange}>
                <option value="planning">Planning</option>
                <option value="in_progress">In Progress</option>
                <option value="completed">Completed</option>
                <option value="cancelled">Cancelled</option>
              </select>
            </div>
          </div>

          <div className="form-group">
            <label>Description</label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleChange}
              rows="4"
              placeholder="Add any additional details about your wedding..."
            />
          </div>

          <div className="form-actions">
            <button type="submit" className="primary" disabled={loading}>
              {loading ? 'Saving...' : isEdit ? 'Update Wedding' : 'Create Wedding'}
            </button>
            <button 
              type="button" 
              className="secondary" 
              onClick={() => navigate('/')}
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};