import { useState, useEffect } from 'react';
import { taskAPI } from '../../services/api';
import './Tasks.css';

export const TaskForm = ({ weddingId, task, onSave, onCancel }) => {
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    priority: 'medium',
    status: 'todo',
    due_date: '',
    assigned_to: '',
    cost: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (task) {
      setFormData(task);
    }
  }, [task]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      if (task) {
        await taskAPI.update(weddingId, task.id, formData);
      } else {
        await taskAPI.create(weddingId, formData);
      }
      onSave();
    } catch (err) {
      setError('Failed to save task');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="card task-form">
      <h3>{task ? 'Edit Task' : 'Add New Task'}</h3>
      
      {error && <div className="alert error">{error}</div>}

      <div className="form-group">
        <label>Task Title *</label>
        <input
          type="text"
          name="title"
          value={formData.title}
          onChange={handleChange}
          required
        />
      </div>

      <div className="form-group">
        <label>Description</label>
        <textarea
          name="description"
          value={formData.description}
          onChange={handleChange}
          rows="3"
        />
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Priority</label>
          <select name="priority" value={formData.priority} onChange={handleChange}>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="urgent">Urgent</option>
          </select>
        </div>
        <div className="form-group">
          <label>Due Date</label>
          <input
            type="date"
            name="due_date"
            value={formData.due_date}
            onChange={handleChange}
          />
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Assigned To</label>
          <input
            type="text"
            name="assigned_to"
            value={formData.assigned_to}
            onChange={handleChange}
            placeholder="Person responsible"
          />
        </div>
        <div className="form-group">
          <label>Cost (TZS)</label>
          <input
            type="number"
            name="cost"
            value={formData.cost}
            onChange={handleChange}
            step="1000"
          />
        </div>
      </div>

      <div className="form-actions">
        <button type="submit" className="primary" disabled={loading}>
          {loading ? 'Saving...' : 'Save Task'}
        </button>
        <button type="button" className="secondary" onClick={onCancel}>
          Cancel
        </button>
      </div>
    </form>
  );
};