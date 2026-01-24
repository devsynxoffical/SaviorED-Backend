import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return (
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100vh',
        background: '#f8fafc',
        gap: '16px',
        color: '#475569'
      }}>
        <div className="spinner" style={{
          width: '32px',
          height: '32px',
          border: '3px solid #cbd5e1',
          borderTop: '3px solid #3b82f6',
          borderRadius: '50%',
          animation: 'spin 1s linear infinite'
        }}></div>
        <div style={{ fontWeight: 500 }}>Connecting to SaviorED Server...</div>
        <div style={{ fontSize: '0.85rem', color: '#94a3b8' }}>This may take up to 30s if the server is sleeping.</div>

        <button
          onClick={() => {
            // Force logout/cancel if stuck
            localStorage.removeItem('admin_token');
            window.location.href = '/login';
          }}
          style={{
            marginTop: '16px',
            padding: '8px 16px',
            border: '1px solid #cbd5e1',
            borderRadius: '6px',
            background: 'white',
            cursor: 'pointer',
            fontSize: '0.85rem'
          }}
        >
          Cancel
        </button>
        <style>{`
          @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        `}</style>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return children;
};

export default ProtectedRoute;

