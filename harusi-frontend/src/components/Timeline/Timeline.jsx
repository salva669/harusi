import { useState, useEffect } from 'react';
import { timelineAPI } from '../../services/api';
import { Loading } from '../Common/Loading';
import './Timeline.css';

export const Timeline = ({ weddingId }) => {
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    event_type: 'other',
    title: '',
    description: '',
    date: '',
    time: '',
    location: '',
  });

  useEffect(() => {
    loadEvents();
  }, [weddingId]);

  const loadEvents = async () => {
    try {
      const response = await timelineAPI.getAll(weddingId);
      setEvents(response.data);
    } catch (err) {
      console.error('Failed to load timeline');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await timelineAPI.create(weddingId, formData);
      loadEvents();
      setShowForm(false);
      setFormData({ event_type: 'other', title: '', description: '', date: '', time: '', location: '' });
    } catch (err) {
      console.error('Failed to create event');
    }
  };

  const handleToggleComplete = async (eventId, isCompleted) => {
    try {
      await timelineAPI.toggleCompleted(weddingId, eventId);
      loadEvents();
    } catch (err) {
      console.error('Failed to update event');
    }
  };

  if (loading) return <Loading />;

  return (
    <div className="timeline-container">
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
        <h2>📅 Wedding Timeline</h2>
        <button className="primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? '✕ Cancel' : '+ Add Event'}
        </button>
      </div>

      {showForm && (
        <form onSubmit={handleSubmit} className="card timeline-form">
          <div className="form-row">
            <div className="form-group">
              <label>Event Type</label>
              <select value={formData.event_type} onChange={(e) => setFormData({ ...formData, event_type: e.target.value })}>
                <option value="save_date">Save the Date</option>
                <option value="invitation">Send Invitations</option>
                <option value="rsvp_deadline">RSVP Deadline</option>
                <option value="final_headcount">Final Headcount</option>
                <option value="ceremony_rehearsal">Ceremony Rehearsal</option>
                <option value="wedding_day">Wedding Day</option>
                <option value="honeymoon">Honeymoon</option>
                <option value="thank_you">Send Thank You Cards</option>
                <option value="other">Other</option>
              </select>
            </div>
            <div className="form-group">
              <label>Title</label>
              <input type="text" value={formData.title} onChange={(e) => setFormData({ ...formData, title: e.target.value })} required />
            </div>
          </div>

          <div className="form-group">
            <label>Description</label>
            <textarea value={formData.description} onChange={(e) => setFormData({ ...formData, description: e.target.value })} />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Date</label>
              <input type="date" value={formData.date} onChange={(e) => setFormData({ ...formData, date: e.target.value })} required />
            </div>
            <div className="form-group">
              <label>Time</label>
              <input type="time" value={formData.time} onChange={(e) => setFormData({ ...formData, time: e.target.value })} />
            </div>
          </div>

          <div className="form-group">
            <label>Location</label>
            <input type="text" value={formData.location} onChange={(e) => setFormData({ ...formData, location: e.target.value })} />
          </div>

          <button type="submit" className="primary">Add Event</button>
        </form>
      )}

      <div className="timeline-vertical">
        {events.map((event, index) => (
          <div key={event.id} className={`timeline-event ${event.is_completed ? 'completed' : ''}`}>
            <div className="timeline-marker">
              <input
                type="checkbox"
                checked={event.is_completed}
                onChange={(e) => handleToggleComplete(event.id, !event.is_completed)}
              />
            </div>
            <div className="timeline-content card">
              <h3>{event.title}</h3>
              <p className="event-type">{event.event_type.replace('_', ' ').toUpperCase()}</p>
              <p className="event-date">📅 {new Date(event.date).toLocaleDateString()}</p>
              {event.time && <p>🕐 {event.time}</p>}
              {event.location && <p>📍 {event.location}</p>}
              {event.description && <p>{event.description}</p>}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};