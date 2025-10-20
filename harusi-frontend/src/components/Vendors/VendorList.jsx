import { useState, useEffect } from 'react';
import { vendorAPI } from '../../services/api';
import { VendorForm } from './VendorForm';
import { Loading } from '../Common/Loading';
import './Vendors.css';

export const VendorList = ({ weddingId }) => {
  const [vendors, setVendors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingVendor, setEditingVendor] = useState(null);
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    loadVendors();
  }, [weddingId]);

  const loadVendors = async () => {
    try {
      const response = await vendorAPI.getAll(weddingId);
      setVendors(response.data);
    } catch (err) {
      console.error('Failed to load vendors');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (vendorId) => {
    if (window.confirm('Delete this vendor?')) {
      try {
        await vendorAPI.delete(weddingId, vendorId);
        setVendors(vendors.filter(v => v.id !== vendorId));
      } catch (err) {
        console.error('Failed to delete vendor');
      }
    }
  };

  const handleSave = () => {
    loadVendors();
    setShowForm(false);
    setEditingVendor(null);
  };

  if (loading) return <Loading />;

  const vendorTypes = [...new Set(vendors.map(v => v.vendor_type))];
  const statuses = {
    inquiry: vendors.filter(v => v.status === 'inquiry').length,
    negotiating: vendors.filter(v => v.status === 'negotiating').length,
    booked: vendors.filter(v => v.status === 'booked').length,
    completed: vendors.filter(v => v.status === 'completed').length,
  };

  const filteredVendors = vendors.filter(v => 
    filter === 'all' ? true : v.status === filter
  );

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
        <h2>💼 Vendor Management</h2>
        <button className="primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? '✕ Cancel' : '+ Add Vendor'}
        </button>
      </div>
  
      {showForm && (
        <VendorForm 
          weddingId={weddingId}
          vendor={editingVendor}
          onSave={handleSave}
          onCancel={() => { setShowForm(false); setEditingVendor(null); }}
        />
      )}
  
      <div className="vendor-filters">
        <button 
          className={`filter-btn ${filter === 'all' ? 'active' : ''}`}
          onClick={() => setFilter('all')}
        >
          All ({vendors.length})
        </button>
        <button 
          className={`filter-btn ${filter === 'inquiry' ? 'active' : ''}`}
          onClick={() => setFilter('inquiry')}
        >
          Inquiry ({statuses.inquiry})
        </button>
        <button 
          className={`filter-btn ${filter === 'negotiating' ? 'active' : ''}`}
          onClick={() => setFilter('negotiating')}
        >
          Negotiating ({statuses.negotiating})
        </button>
        <button 
          className={`filter-btn ${filter === 'booked' ? 'active' : ''}`}
          onClick={() => setFilter('booked')}
        >
          Booked ({statuses.booked})
        </button>
        <button 
          className={`filter-btn ${filter === 'completed' ? 'active' : ''}`}
          onClick={() => setFilter('completed')}
        >
          Completed ({statuses.completed})
        </button>
      </div>
  
      {filteredVendors.length === 0 ? (
        <div className="empty-state">
          <p>No vendors found</p>
        </div>
      ) : (
        <div className="vendors-grid">
          {filteredVendors.map(vendor => (
            <div key={vendor.id} className="vendor-card card">
              <div className="vendor-header">
                <div>
                  <h3>{vendor.business_name}</h3>
                  <p className="vendor-type">{vendor.vendor_type.replace('_', ' ')}</p>
                </div>
                <span className={`status-badge ${vendor.status}`}>
                  {vendor.status}
                </span>
              </div>
  
              <div className="vendor-contact">
                <p><strong>Contact:</strong> {vendor.contact_person}</p>
                <p>📱 {vendor.phone}</p>
                <p>✉️ {vendor.email}</p>
                {vendor.website && <p><a href={vendor.website} target="_blank" rel="noopener noreferrer">🌐 Website</a></p>}
              </div>
  
              <div className="vendor-pricing">
                {vendor.quote && <p>Quote: TZS {vendor.quote.toLocaleString()}</p>}
                {vendor.deposit_paid && <p>Deposit: TZS {vendor.deposit_paid.toLocaleString()}</p>}
                {vendor.final_amount && <p>Final: TZS {vendor.final_amount.toLocaleString()}</p>}
                {vendor.remaining_amount && <p className="remaining">Remaining: TZS {vendor.remaining_amount.toLocaleString()}</p>}
              </div>
  
              {vendor.vendor_notes && <p className="vendor-notes"><strong>Notes:</strong> {vendor.vendor_notes}</p>}
  
              {vendor.note_entries && vendor.note_entries.length > 0 && (
                <div className="vendor-note-entries">
                  <h4>Additional Notes:</h4>
                  {vendor.note_entries.map(note => (
                    <div key={note.id} className="note-entry">
                      <p>{note.content}</p>
                      <small>by {note.created_by_username} on {new Date(note.created_at).toLocaleDateString()}</small>
                    </div>
                  ))}
                </div>
              )}
  
              <div className="vendor-actions">
                <button 
                  className="secondary" 
                  onClick={() => { setEditingVendor(vendor); setShowForm(true); }}
                >
                  Edit
                </button>
                <button 
                  className="danger" 
                  onClick={() => handleDelete(vendor.id)}
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