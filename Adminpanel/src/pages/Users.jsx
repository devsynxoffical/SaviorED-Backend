import { useState, useEffect } from 'react';
import { usersAPI } from '../services/api';
import DataTable from '../components/DataTable';
import './Users.css';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    loadUsers();
  }, [page, searchQuery]);

  const loadUsers = async () => {
    try {
      setLoading(true);
      const response = await usersAPI.getAll(page, 20);
      if (response.data.success) {
        setUsers(response.data.users);
        setTotalPages(response.data.pagination?.pages || 1);
      }
    } catch (error) {
      console.error('Error loading users:', error);
      setUsers([]);
      setTotalPages(1);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (userId) => {
    if (window.confirm('Are you sure you want to delete this user?')) {
      try {
        await usersAPI.delete(userId);
        loadUsers();
      } catch (error) {
        console.error('Error deleting user:', error);
        alert('Failed to delete user');
      }
    }
  };

  const columns = [
    { key: 'id', label: 'ID' },
    {
      key: 'name',
      label: 'Name',
      render: (value, row) => (
        <div className="user-cell">
          {row.avatar && (
            <img src={row.avatar} alt={value} className="user-avatar" />
          )}
          <span>{value || 'N/A'}</span>
        </div>
      ),
    },
    { key: 'email', label: 'Email' },
    {
      key: 'createdAt',
      label: 'Created At',
      render: (value) => (value ? new Date(value).toLocaleDateString() : '-'),
    },
  ];

  return (
    <div className="users-page">
      <div className="page-header">
        <h2>Users Management</h2>
        <div className="page-actions">
          <input
            type="text"
            placeholder="Search users..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="search-input"
          />
        </div>
      </div>

      <DataTable
        columns={columns}
        data={users}
        loading={loading}
        actions={(row) => (
          <>
            <button className="btn-view" onClick={() => alert(`View user ${row.id}`)}>
              View
            </button>
            <button className="btn-edit" onClick={() => alert(`Edit user ${row.id}`)}>
              Edit
            </button>
            <button className="btn-delete" onClick={() => handleDelete(row.id)}>
              Delete
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

export default Users;

