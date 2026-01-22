import { useState, useEffect } from 'react';
import { guestAPI } from '../../services/api';
import { GuestForm } from './GuestForm';
import { Loading } from '../Common/Loading';
import './Guests.css';

export const GuestList = ({ weddingId }) => {
  const [guests, setGuests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingGuest, setEditingGuest] = useState(null);

  useEffect(() => {
    loadGuests();
  }, [weddingId]);

  const loadGuests = async () => {
    try {
      const response = await guestAPI.getAll(weddingId);
      setGuests(response.data);
    } catch (err) {
      console.error('Failed to load guests');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (guestId) => {
    if (window.confirm('Remove this guest?')) {
      try {
        await guestAPI.delete(weddingId, guestId);
        setGuests(guests.filter(g => g.id !== guestId));
      } catch (err) {
        console.error('Failed to delete guest');
      }
    }
  };

  const handleSave = () => {
    loadGuests();
    setShowForm(false);
    setEditingGuest(null);
  };
  
  if (loading) return <Loading />;

  const rsvpStats = {
    confirmed: guests.filter(g => g.rsvp_status === 'confirmed').length,
    pending: guests.filter(g => g.rsvp_status === 'pending').length,
    declined: guests.filter(g => g.rsvp_status === 'declined').length,
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
        <h2>Guest Management</h2>
        <button className="primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? '✕ Cancel' : '+ Add Guest'}
        </button>
      </div>

      {showForm && (
        <GuestForm 
          weddingId={weddingId} 
          guest={editingGuest}
          onSave={handleSave}
          onCancel={() => { setShowForm(false); setEditingGuest(null); }}
        />
      )}

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-number">{rsvpStats.confirmed}</div>
          <div className="stat-label">Confirmed</div>
        </div>
        <div className="stat-card">
          <div className="stat-number">{rsvpStats.pending}</div>
          <div className="stat-label">Pending</div>
        </div>
        <div className="stat-card">
          <div className="stat-number">{rsvpStats.declined}</div>
          <div className="stat-label">Declined</div>
        </div>
        <div className="stat-card">
          <div className="stat-number">{guests.length}</div>
          <div className="stat-label">Total Guests</div>
        </div>
      </div>

      {guests.length === 0 ? (
        <div className="empty-state">
          <p>No guests yet. Start adding them!</p>
        </div>
      ) : (
        <div className="guest-list">
          {guests.map(guest => (
            <div key={guest.id} className="guest-card card">
              <div className="guest-header">
                <div>
                  <h3>{guest.name}</h3>
                  <p className="guest-meta">{guest.relationship}</p>
                </div>
                <span className={`rsvp-badge ${guest.rsvp_status}`}>
                  {guest.rsvp_status}
                </span>
              </div>
              <div className="guest-details">
                {guest.email && <p>✉️ {guest.email}</p>}
                {guest.phone && <p>📱 {guest.phone}</p>}
                <p>👥 {guest.number_of_guests} {guest.number_of_guests > 1 ? 'guests' : 'guest'}</p>
              </div>
              <div className="guest-actions">
                <button 
                  className="secondary" 
                  onClick={() => { setEditingGuest(guest); setShowForm(true); }}
                >
                  Edit
                </button>
                <button 
                  className="danger" 
                  onClick={() => handleDelete(guest.id)}
                >
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};