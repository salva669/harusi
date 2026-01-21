const HarusiLogo = ({ size = 32, className = "" }) => (
  <svg 
    width={size} 
    height={size} 
    viewBox="0 0 80 80" 
    xmlns="http://www.w3.org/2000/svg"
    className={className}
  >
    <g transform="translate(40, 40)">
      <circle cx="-15" cy="0" r="25" fill="none" stroke="#ec4899" strokeWidth="6"/>
      <circle cx="15" cy="0" r="25" fill="none" stroke="#f472b6" strokeWidth="6"/>
      <text x="0" y="8" fontFamily="Arial, sans-serif" fontSize="28" fontWeight="bold" textAnchor="middle" fill="#ec4899">
        H
      </text>
    </g>
  </svg>
);

export default HarusiLogo;