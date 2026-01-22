import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import api from '../../services/api';
import './Auth.css';
import { Heart } from 'lucide-react';
import HarusiLogo from '../Common/HarusiLogo';

export const Login = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { login } = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await api.post('/auth-token/', { username, password });
      const token = response.data.token;
      
      // Get user info
      const userResponse = await api.get('/user/', {
        headers: { Authorization: `Token ${token}` }
      });
      
      login(token, userResponse.data);
      navigate('/');
    } catch (err) {
      setError(err.response?.data?.non_field_errors?.[0] || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
  <div className="auth-card">
    <div className="auth-header">
      <Heart className="heart-icon" />
      <h1 className="single-line-header">
        Welcome to Harusi Yangu 
        <HarusiLogo size={32} style={{ marginLeft: '8px' }} />
      </h1>
      <p>Plan your perfect wedding</p>
    </div>
    
    {error && <div className="alert error">{error}</div>}
    
    <form onSubmit={handleSubmit}>
      <div className="form-group">
        <label>Username</label>
        <input
          type="text"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          required
        />
      </div>
      
      <div className="form-group">
        <label>Password</label>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
      </div>

      <div className="forgot-password">
        <Link to="/forgot-password">Forgot Password?</Link>
      </div>
      
      <button type="submit" className="primary" disabled={loading}>
        {loading ? 'Logging in...' : 'Login'}
      </button>
    </form>
    
    <p className="auth-link">
      Don't have an account? <Link to="/register">Sign Up</Link>
    </p>
  </div>
</div>
  );
};