import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Heart, Users, Briefcase, Eye, EyeOff } from 'lucide-react';
import api from '../../services/api';
import './Auth.css';

export const Register = () => {
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [confirmEmail, setConfirmEmail] = useState('');
  const [countryCode, setCountryCode] = useState('+255'); // Default to Tanzania
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [userType, setUserType] = useState('couple');
  const [acceptTerms, setAcceptTerms] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const countryCodes = [
    { code: '+255', country: 'Tanzania', flag: '🇹🇿' },
    { code: '+254', country: 'Kenya', flag: '🇰🇪' },
    { code: '+256', country: 'Uganda', flag: '🇺🇬' },
    { code: '+250', country: 'Rwanda', flag: '🇷🇼' },
    { code: '+1', country: 'USA/Canada', flag: '🇺🇸' },
    { code: '+44', country: 'UK', flag: '🇬🇧' },
    { code: '+27', country: 'South Africa', flag: '🇿🇦' },
    { code: '+234', country: 'Nigeria', flag: '🇳🇬' },
    { code: '+91', country: 'India', flag: '🇮🇳' },
    { code: '+86', country: 'China', flag: '🇨🇳' },
  ];

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (!acceptTerms) {
      setError('Please accept the terms and conditions');
      return;
    }

    if (email !== confirmEmail) {
      setError('Email addresses do not match');
      return;
    }

    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    if (password.length < 6) {
      setError('Password must be at least 6 characters');
      return;
    }

    setLoading(true);

    try {
      const fullPhone = `${countryCode}${phone}`;
      await api.post('/register/', { 
        username, 
        email, 
        phone: fullPhone,
        password,
        user_type: userType 
      });
      navigate('/login');
    } catch (err) {
      setError(err.response?.data?.username?.[0] || err.response?.data?.email?.[0] || 'Registration failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-card register-card">
        <div className="auth-header">
          <Heart className="heart-icon" />
          <h1>Create Account</h1>
          <p>Join us to plan your perfect wedding</p>
        </div>
        
        {error && <div className="alert error">{error}</div>}
        
        <form onSubmit={handleSubmit}>
          {/* User Type Selection */}
          <div className="form-group">
            <label>I am a:</label>
            <div className="user-type-chips">
              <button
                type="button"
                className={`user-type-chip ${userType === 'couple' ? 'selected' : ''}`}
                onClick={() => setUserType('couple')}
              >
                <Heart size={24} />
                <span>Couple</span>
              </button>
              <button
                type="button"
                className={`user-type-chip ${userType === 'vendor' ? 'selected' : ''}`}
                onClick={() => setUserType('vendor')}
              >
                <Briefcase size={24} />
                <span>Vendor</span>
              </button>
              <button
                type="button"
                className={`user-type-chip ${userType === 'guest' ? 'selected' : ''}`}
                onClick={() => setUserType('guest')}
              >
                <Users size={24} />
                <span>Guest</span>
              </button>
            </div>
          </div>

          <div className="form-group">
            <label>Username</label>
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="Choose a username"
              required
              minLength={3}
            />
          </div>
          
          <div className="form-group">
            <label>Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Enter your email"
              required
            />
          </div>

          <div className="form-group">
            <label>Confirm Email</label>
            <input
              type="email"
              value={confirmEmail}
              onChange={(e) => setConfirmEmail(e.target.value)}
              placeholder="Re-enter your email"
              required
            />
          </div>

          <div className="form-group">
            <label>Phone Number</label>
            <div className="phone-input-group">
              <select 
                className="country-code-select"
                value={countryCode}
                onChange={(e) => setCountryCode(e.target.value)}
              >
                {countryCodes.map((country) => (
                  <option key={country.code} value={country.code}>
                    {country.flag} {country.code}
                  </option>
                ))}
              </select>
              <input
                type="tel"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="712345678"
                required
                className="phone-number-input"
              />
            </div>
          </div>
          
          <div className="form-group">
            <label>Password</label>
            <div className="password-input-wrapper">
              <input
                type={showPassword ? "text" : "password"}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Create a password"
                required
                minLength={6}
              />
              <button
                type="button"
                className="password-toggle"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
              </button>
            </div>
          </div>
          
          <div className="form-group">
            <label>Confirm Password</label>
            <div className="password-input-wrapper">
              <input
                type={showConfirmPassword ? "text" : "password"}
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Re-enter your password"
                required
              />
              <button
                type="button"
                className="password-toggle"
                onClick={() => setShowConfirmPassword(!showConfirmPassword)}
              >
                {showConfirmPassword ? <EyeOff size={20} /> : <Eye size={20} />}
              </button>
            </div>
          </div>

          <div className="terms-checkbox">
            <input
              type="checkbox"
              id="terms"
              checked={acceptTerms}
              onChange={(e) => setAcceptTerms(e.target.checked)}
            />
            <label htmlFor="terms">
              I agree to the <span className="terms-link">Terms and Conditions</span>
            </label>
          </div>
          
          <button type="submit" className="primary" disabled={loading}>
            {loading ? 'Creating account...' : 'Create Account'}
          </button>
        </form>
        
        <p className="auth-link">
          Already have an account? <Link to="/login">Login here</Link>
        </p>
      </div>
    </div>
  );
};