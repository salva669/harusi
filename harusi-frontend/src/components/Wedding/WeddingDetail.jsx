import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { weddingAPI } from '../../services/api';
import { Loading } from '../Common/Loading';
import { GuestList } from '../Guests/GuestList';
import { TaskList } from '../Tasks/TaskList';
import { BudgetSummary } from '../Budget/BudgetSummary';
import './Wedding.css';

export const WeddingDetail = () => {
  const [wedding, setWedding] = useState(null);
  const [summary, setSummary] = useState(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('overview');
  const { id } = useParams();

  useEffect(() => {
    loadWeddingData();
  }, [id]);

  const loadWeddingData = async () => {
    try {
      const weddingRes = await weddingAPI.getOne(id);
      const summaryRes = await weddingAPI.getSummary(id);
      setWedding(weddingRes.data);
      setSummary(summaryRes.data);
    } catch (err) {
      console.error('Failed to load wedding details');
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <Loading />;
  if (!wedding) return <div>Wedding not found</div>;

  const weddingDate = new Date(wedding.wedding_date);
  const daysUntil = Math.ceil((weddingDate - new Date()) / (1000 * 60 * 60 * 24));

  return (
    <div className="wedding-detail">
      <div className="wedding-detail-header">
        <h1>💒 {wedding.bride_name} & {wedding.groom_name}</h1>
        <p style={{ fontSize: '1.1rem', marginTop: '10px' }}>
          {daysUntil > 0 
            ? `${daysUntil} days to go! 🎉` 
            : daysUntil === 0 
            ? `Today is the day! 🎊` 
            : `Wedding was ${Math.abs(daysUntil)} days ago`}
        </p>
      </div>

      {summary && (
        <div className="wedding-detail-info">
          <div className="info-item">
            <label>Date</label>
            <p>📅 {weddingDate.toLocaleDateString()}</p>
          </div>
          <div className="info-item">
            <label>Venue</label>
            <p>📍 {wedding.venue}</p>
          </div>
          <div className="info-item">
            <label>Guests</label>
            <p>👥 {summary.confirmed_guests}/{summary.total_guests} Confirmed</p>
          </div>
          <div className="info-item">
            <label>Tasks</label>
            <p>✓ {summary.completed_tasks}/{summary.total_tasks} Done</p>
          </div>
        </div>
      )}

      <div className="tabs">
        <button 
          className={`tab-button ${activeTab === 'overview' ? 'active' : ''}`}
          onClick={() => setActiveTab('overview')}
        >
          Overview
        </button>
        <button 
          className={`tab-button ${activeTab === 'guests' ? 'active' : ''}`}
          onClick={() => setActiveTab('guests')}
        >
          Guests
        </button>
        <button 
          className={`tab-button ${activeTab === 'tasks' ? 'active' : ''}`}
          onClick={() => setActiveTab('tasks')}
        >
          Tasks
        </button>
        <button 
          className={`tab-button ${activeTab === 'budget' ? 'active' : ''}`}
          onClick={() => setActiveTab('budget')}
        >
          Budget
        </button>
        <button 
          className={`tab-button ${activeTab === 'gallery' ? 'active' : ''}`}
          onClick={() => setActiveTab('gallery')}
        >
          Gallery
        </button>
        <button 
          className={`tab-button ${activeTab === 'timeline' ? 'active' : ''}`}
          onClick={() => setActiveTab('timeline')}
        >
          Timeline
        </button>
        <button 
          className={`tab-button ${activeTab === 'vendors' ? 'active' : ''}`}
          onClick={() => setActiveTab('vendors')}
        >
          Vendors
        </button>
        <button 
          className={`tab-button ${activeTab === 'reports' ? 'active' : ''}`}
          onClick={() => setActiveTab('reports')}
        >
          Reports
        </button>
      </div>

      <div className={`tab-content ${activeTab === 'overview' ? 'active' : ''}`}>
        <div className="card">
          <h2>Wedding Details</h2>
          <p><strong>Status:</strong> {wedding.status}</p>
          <p><strong>Budget:</strong> TZS {wedding.budget.toLocaleString()}</p>
          <p><strong>Description:</strong> {wedding.description || 'No description'}</p>
          <div style={{ marginTop: '20px' }}>
            <Link to={`/weddings/${id}/edit`} className="button primary">
              Edit Wedding
            </Link>
          </div>
        </div>
      </div>

      <div className={`tab-content ${activeTab === 'guests' ? 'active' : ''}`}>
        <GuestList weddingId={id} />
      </div>

      <div className={`tab-content ${activeTab === 'tasks' ? 'active' : ''}`}>
        <TaskList weddingId={id} />
      </div>

      <div className={`tab-content ${activeTab === 'budget' ? 'active' : ''}`}>
        <BudgetSummary weddingId={id} />
      </div>

      <div className={`tab-content ${activeTab === 'gallery' ? 'active' : ''}`}>
        <PhotoGallery weddingId={id} />
      </div>

      <div className={`tab-content ${activeTab === 'timeline' ? 'active' : ''}`}>
        <Timeline weddingId={id} />
      </div>

      <div className={`tab-content ${activeTab === 'vendors' ? 'active' : ''}`}>
        <VendorList weddingId={id} />
      </div>

      <div className={`tab-content ${activeTab === 'reports' ? 'active' : ''}`}>
        <PDFDownloads weddingId={id} />
      </div>
    </div>
  );
};