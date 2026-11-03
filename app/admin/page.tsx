import AdminPanel from '../admin-panel';
export const dynamic='force-dynamic';
// AdminPanel refreshes the existing session before loading owner-only APIs.
// Private orders and catalog writes remain authorized on the server.
export default function AdminPage(){return <AdminPanel/>;}
