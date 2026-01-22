import { useState, useEffect } from 'react';
import { guestAPI } from '../../services/api';
import './Guests.css';

export const GuestForm = ({ weddingId, guest, onSave, onCancel }) => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    relationship: 'friend',
    rsvp_status: 'pending',
    number_of_guests: 1,
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [countryCode, setCountryCode] = useState('+255');
  const [phone, setPhone] = useState('');

  const countryCodes = [
    { code: '+255', flag: '🇹🇿', country: 'Tanzania' },
    { code: '+254', flag: '🇰🇪', country: 'Kenya' },
    { code: '+256', flag: '🇺🇬', country: 'Uganda' },
    { code: '+250', flag: '🇷🇼', country: 'Rwanda' },
    { code: '+1', flag: '🇺🇸', country: 'USA' },
    { code: '+44', flag: '🇬🇧', country: 'UK' },
  ];

  useEffect(() => {
    if (guest) {
      setFormData(guest);
      // Parse existing phone number if it has country code
      if (guest.phone) {
        const matchedCode = countryCodes.find(c => guest.phone.startsWith(c.code));
        if (matchedCode) {
          setCountryCode(matchedCode.code);
          setPhone(guest.phone.substring(matchedCode.code.length));
        } else {
          setPhone(guest.phone);
        }
      }
    }
  }, [guest]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    // Validate phone number length
    if (phone && phone.length !== 9) {
      setError('Phone number must be exactly 9 digits');
      setLoading(false);
      return;
    }

    try {
      // Combine country code and phone number
      const fullPhone = phone ? `${countryCode}${phone}` : '';
      const dataToSubmit = {
        ...formData,
        phone: fullPhone
      };

      if (guest) {
        await guestAPI.update(weddingId, guest.id, dataToSubmit);
      } else {
        await guestAPI.create(weddingId, dataToSubmit);
      }
      onSave();
    } catch (err) {
      console.error('Error details:', err.response?.data);
      setError('Failed to save guest');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="card guest-form">
      <h3>{guest ? 'Edit Guest' : 'Add New Guest'}</h3>
      
      {error && <div className="alert error">{error}</div>}

      <div className="form-row">
        <div className="form-group">
          <label>Guest Name *</label>
          <input
            type="text"
            name="name"
            value={formData.name}
            onChange={handleChange}
            required
          />
        </div>
        <div className="form-group">
          <label>Relationship</label>
          <select name="relationship" value={formData.relationship} onChange={handleChange}>
            <option value="family">Family</option>
            <option value="friend">Friend</option>
            <option value="colleague">Colleague</option>
            <option value="other">Other</option>
          </select>
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>Email</label>
          <input
            type="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
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
              onChange={(e) => {
                const value = e.target.value.replace(/\D/g, ''); // Remove non-digits
                if (value.length <= 9) {
                  setPhone(value);
                }
              }}
              placeholder="712345678"
              className="phone-number-input"
              pattern="[0-9]{9}"
              maxLength="9"
              minLength="9"
              title="Please enter exactly 9 digits"
            />
          </div>
        </div>
      </div>

      <div className="form-row">
        <div className="form-group">
          <label>RSVP Status</label>
          <select name="rsvp_status" value={formData.rsvp_status} onChange={handleChange}>
            <option value="pending">Pending</option>
            <option value="confirmed">Confirmed</option>
            <option value="declined">Declined</option>
          </select>
        </div>
        <div className="form-group">
          <label>Number of Guests</label>
          <input
            type="number"
            name="number_of_guests"
            value={formData.number_of_guests}
            onChange={handleChange}
            min="1"
          />
        </div>
      </div>

      <div className="form-actions">
        <button type="submit" className="primary" disabled={loading}>
          {loading ? 'Saving...' : 'Save Guest'}
        </button>
        <button type="button" className="secondary" onClick={onCancel}>
          Cancel
        </button>
      </div>
    </form>
  );
};