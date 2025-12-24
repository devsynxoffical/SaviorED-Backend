import { useState, useEffect } from 'react';
import { castleGroundsAPI } from '../services/api';
import DataTable from '../components/DataTable';
import './CastleGrounds.css';

const CastleGrounds = () => {
  const [castles, setCastles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    loadCastles();
  }, [page]);

  const loadCastles = async () => {
    try {
      setLoading(true);
      const response = await castleGroundsAPI.getAll(page, 20);
      // Mock data for development
      const mockCastles = Array.from({ length: 20 }, (_, i) => ({
        id: `castle-${i + 1}`,
        userId: `user-${Math.floor(Math.random() * 50) + 1}`,
        coins: Math.floor(Math.random() * 10000),
        stones: Math.floor(Math.random() * 5000),
        wood: Math.floor(Math.random() * 3000),
        level: Math.floor(Math.random() * 20) + 1,
        levelName: `Level ${Math.floor(Math.random() * 20) + 1}`,
        progressPercentage: Math.random() * 100,
        updatedAt: new Date(Date.now() - Math.random() * 10000000000).toISOString(),
      }));
      setCastles(mockCastles);
      setTotalPages(5);
    } catch (error) {
      console.error('Error loading castles:', error);
      const mockCastles = Array.from({ length: 20 }, (_, i) => ({
        id: `castle-${i + 1}`,
        userId: `user-${Math.floor(Math.random() * 50) + 1}`,
        coins: Math.floor(Math.random() * 10000),
        stones: Math.floor(Math.random() * 5000),
        wood: Math.floor(Math.random() * 3000),
        level: Math.floor(Math.random() * 20) + 1,
        levelName: `Level ${Math.floor(Math.random() * 20) + 1}`,
        progressPercentage: Math.random() * 100,
        updatedAt: new Date(Date.now() - Math.random() * 10000000000).toISOString(),
      }));
      setCastles(mockCastles);
      setTotalPages(5);
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    { key: 'id', label: 'Castle ID' },
    { key: 'userId', label: 'User ID' },
    { key: 'level', label: 'Level' },
    { key: 'levelName', label: 'Level Name' },
    {
      key: 'coins',
      label: 'Resources',
      render: (value, row) => (
        <div className="resources-cell">
          <span>💰 {value.toLocaleString()}</span>
          <span>🪨 {row.stones.toLocaleString()}</span>
          <span>🪵 {row.wood.toLocaleString()}</span>
        </div>
      ),
    },
    {
      key: 'progressPercentage',
      label: 'Progress',
      render: (value) => (
        <div className="progress-bar-container">
          <div className="progress-bar" style={{ width: `${value}%` }}></div>
          <span className="progress-text">{value.toFixed(1)}%</span>
        </div>
      ),
    },
    {
      key: 'updatedAt',
      label: 'Last Updated',
      render: (value) => (value ? new Date(value).toLocaleString() : '-'),
    },
  ];

  return (
    <div className="castle-grounds-page">
      <div className="page-header">
        <h2>Castle Grounds</h2>
      </div>

      <DataTable
        columns={columns}
        data={castles}
        loading={loading}
        actions={(row) => (
          <>
            <button className="btn-view" onClick={() => alert(`View castle ${row.id}`)}>
              View
            </button>
            <button className="btn-edit" onClick={() => alert(`Edit castle ${row.id}`)}>
              Edit
            </button>
          </>
        )}
      />

      <div className="pagination">
        <button
          onClick={() => setPage((p) => Math.max(1, p - 1))}
          disabled={page === 1}
        >
          Previous
        </button>
        <span>
          Page {page} of {totalPages}
        </span>
        <button
          onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
          disabled={page === totalPages}
        >
          Next
        </button>
      </div>
    </div>
  );
};

export default CastleGrounds;

