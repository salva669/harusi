import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { weddingAPI } from '../../services/api';
import { Loading } from '../Common/Loading';
import './Wedding.css';

export const WeddingList = () => {
  const [weddings, setWeddings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchWeddings();
  }, []);

  const fetchWeddings = async () => {
    try {
      const response = await weddingAPI.getAll();
      setWeddings(response.data);
    } catch (err) {
      setError('Failed to load weddings');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this wedding?')) {
      try {
        await weddingAPI.delete(id);
        setWeddings(weddings.filter(w => w.id !== id));
      } catch (err) {
        setError('Failed to delete wedding');
      }
    }
  };

  if (loading) return <Loading />;

  return (
    <div className="container">
      <div className="page-header">
        <h1>My Weddings</h1>
        <Link to="/weddings/new" className="button primary">+ New Wedding</Link>
      </div>

      {error && <div className="alert error">{error}</div>}

      {weddings.length === 0 ? (
        <div className="empty-state">
          <p>No weddings yet. Start planning your big day!</p>
          <Link to="/weddings/new" className="button primary">Create Wedding</Link>
        </div>
      ) : (
        <div className="wedding-grid">
          {weddings.map(wedding => (
            <div key={wedding.id} className="wedding-card card">
              <div className="wedding-card-header">
                <h2>{wedding.bride_name} & {wedding.groom_name}</h2>
                <span className={`status-badge ${wedding.status}`}>
                  {wedding.status}
                </span>
              </div>
              <p className="wedding-date">
                📅 {new Date(wedding.wedding_date).toLocaleDateString()}
              </p>
              <p className="wedding-venue">📍 {wedding.venue}</p>
              <p className="wedding-budget">💰 {wedding.budget}</p>
              <div className="wedding-card-actions">
                <Link to={`/weddings/${wedding.id}`} className="button primary">
                  View Details
                </Link>
                <button 
                  onClick={() => handleDelete(wedding.id)} 
                  className="button danger"
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