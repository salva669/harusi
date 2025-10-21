import { useState, useEffect } from 'react';
import { pledgeAPI } from '../../services/api';
import { PledgeForm } from './PledgeForm';
import { PledgeSummary } from './PledgeSummary';
import { Loading } from '../Common/Loading';
import './Pledges.css';

export const PledgeManagement = ({ weddingId }) => {
  const [pledges, setPledges] = useState([]);
  const [summary, setSummary] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingPledge, setEditingPledge] = useState(null);
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    loadData();
  }, [weddingId]);

  const loadData = async () => {
    try {
      const [pledgesRes, summaryRes] = await Promise.all([
        pledgeAPI.getAll(weddingId),
        pledgeAPI.getSummary(weddingId)
      ]);
      setPledges(pledgesRes.data);
      setSummary(summaryRes.data);
    } catch (err) {
      console.error('Failed to load pledges');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (pledgeId) => {
    if (window.confirm('Delete this pledge?')) {
      try {
        await pledgeAPI.delete(weddingId, pledgeId);
        loadData();
      } catch (err) {
        console.error('Failed to delete pledge');
      }
    }
  };

  const handleSave = () => {
    loadData();
    setShowForm(false);
    setEditingPledge(null);
  };

  if (loading) return <Loading />;

  const filteredPledges = pledges.filter(p => 
    filter === 'all' ? true : p.payment_status === filter
  );

  return (
    <div className="pledge-management">
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
        <h2>💰 Guest Contributions & Pledges</h2>
        <button className="primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? '✕ Cancel' : '+ Add Pledge'}
        </button>
      </div>

      {showForm && (
        <PledgeForm 
          weddingId={weddingId}
          pledge={editingPledge}
          onSave={handleSave}
          onCancel={() => { setShowForm(false); setEditingPledge(null); }}
        />
      )}

      {summary && <PledgeSummary summary={summary} />}

      <div className="pledge-filters">
        <button 
          className={`filter-btn ${filter === 'all' ? 'active' : ''}`}
          onClick={() => setFilter('all')}
        >
          All ({pledges.length})
        </button>
        <button 
          className={`filter-btn ${filter === 'pledged' ? 'active' : ''}`}
          onClick={() => setFilter('pledged')}
        >
          Pledged ({summary?.status_breakdown.pledged || 0})
        </button>
        <button 
          className={`filter-btn ${filter === 'partial' ? 'active' : ''}`}
          onClick={() => setFilter('partial')}
        >
          Partial ({summary?.status_breakdown.partial || 0})
        </button>
        <button 
          className={`filter-btn ${filter === 'paid' ? 'active' : ''}`}
          onClick={() => setFilter('paid')}
        >
          Paid ({summary?.status_breakdown.paid || 0})
        </button>
      </div>

      {filteredPledges.length === 0 ? (
        <div className="empty-state">
          <p>No pledges recorded yet</p>
        </div>
      ) : (
        <div className="pledges-grid">
          {filteredPledges.map(pledge => (
            <div key={pledge.id} className="pledge-card card">
              <div className="pledge-header">
                <div>
                  <h3>{pledge.guest_name}</h3>
                  <p className="pledge-type">{pledge.contribution_type.replace('_', ' ')}</p>
                </div>
                <span className={`status-badge ${pledge.payment_status}`}>
                  {pledge.payment_status}
                </span>
              </div>

              <div className="pledge-amounts">
                <div className="amount-item">
                  <span className="label">Pledged:</span>
                  <span className="value">TZS {pledge.pledged_amount.toLocaleString()}</span>
                </div>
                <div className="amount-item">
                  <span className="label">Paid:</span>
                  <span className="value paid">TZS {pledge.paid_amount.toLocaleString()}</span>
                </div>
                <div className="amount-item">
                  <span className="label">Balance:</span>
                  <span className="value balance">TZS {pledge.balance.toLocaleString()}</span>
                </div>
              </div>

              <div className="progress-bar-container">
                <div className="progress-bar-bg">
                  <div 
                    className="progress-bar-fill"
                    style={{ width: `${pledge.payment_progress}%` }}
                  >
                    {pledge.payment_progress.toFixed(0)}%
                  </div>
                </div>
              </div>

              {pledge.payment_deadline && (
                <p className="deadline">
                  📅 Deadline: {new Date(pledge.payment_deadline).toLocaleDateString()}
                </p>
              )}

              {pledge.notes && <p className="pledge-notes">{pledge.notes}</p>}

              <div className="pledge-actions">
                <button 
                  className="primary" 
                  onClick={() => {
                    // Open payment recording modal
                    // We'll create this next
                  }}
                >
                  Record Payment
                </button>
                <button 
                  className="secondary" 
                  onClick={() => { setEditingPledge(pledge); setShowForm(true); }}
                >
                  Edit
                </button>
                <button 
                  className="danger" 
                  onClick={() => handleDelete(pledge.id)}
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