'use client'

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { 
  Users, 
  BookOpen, 
  DollarSign, 
  Home, 
  Calendar,
  TrendingUp,
  AlertCircle,
  CheckCircle,
  Clock,
  Download,
  Upload,
  Bell,
  Settings,
  Search,
  Filter,
  MoreVertical
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Progress } from '@/components/ui/progress'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { LineChart, Line, BarChart, Bar, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'
import { useQuery } from 'react-query'
import axios from 'axios'
import { toast } from 'react-hot-toast'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'

interface DashboardStats {
  summary: {
    santri_aktif: number
    ustadz_aktif: number
    kamar_tersedia: number
    transaksi_30hari: number
  }
  financial: {
    total_paid: number
    total_pending: number
    total_transactions: number
  }
  academic: {
    rata_rata_nilai: number
    total_santri_terlibat: number
    total_nilai: number
  }
}

interface RecentActivity {
  id: string
  type: string
  description: string
  user: string
  time: string
  status: 'success' | 'warning' | 'error'
}

interface QuickStats {
  title: string
  value: string | number
  change: string
  icon: React.ReactNode
  color: string
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [loading, setLoading] = useState(true)

  const { data: dashboardData, isLoading } = useQuery('dashboard', async () => {
    const response = await axios.get(`${API_URL}/api/dashboard/summary`)
    return response.data
  }, {
    refetchInterval: 30000, // Refresh every 30 seconds
  })

  useEffect(() => {
    if (dashboardData) {
      setStats(dashboardData)
      setLoading(false)
    }
  }, [dashboardData])

  const quickStats: QuickStats[] = [
    {
      title: 'Santri Aktif',
      value: stats?.summary.santri_aktif || 0,
      change: '+12%',
      icon: <Users className="h-6 w-6" />,
      color: 'bg-blue-500'
    },
    {
      title: 'Transaksi Bulan Ini',
      value: stats?.summary.transaksi_30hari || 0,
      change: '+24%',
      icon: <DollarSign className="h-6 w-6" />,
      color: 'bg-green-500'
    },
    {
      title: 'Kamar Tersedia',
      value: stats?.summary.kamar_tersedia || 0,
      change: '-5%',
      icon: <Home className="h-6 w-6" />,
      color: 'bg-purple-500'
    },
    {
      title: 'Rata-rata Nilai',
      value: stats?.academic.rata_rata_nilai ? stats.academic.rata_rata_nilai.toFixed(1) : '0.0',
      change: '+3.2%',
      icon: <BookOpen className="h-6 w-6" />,
      color: 'bg-orange-500'
    }
  ]

  const financialData = [
    { month: 'Jan', paid: 45000000, pending: 12000000 },
    { month: 'Feb', paid: 52000000, pending: 15000000 },
    { month: 'Mar', paid: 48000000, pending: 18000000 },
    { month: 'Apr', paid: 55000000, pending: 20000000 },
    { month: 'May', paid: 60000000, pending: 22000000 },
    { month: 'Jun', paid: 65000000, pending: 25000000 },
  ]

  const attendanceData = [
    { day: 'Sen', present: 95, absent: 5 },
    { day: 'Sel', present: 92, absent: 8 },
    { day: 'Rab', present: 98, absent: 2 },
    { day: 'Kam', present: 90, absent: 10 },
    { day: 'Jum', present: 96, absent: 4 },
    { day: 'Sab', present: 94, absent: 6 },
    { day: 'Min', present: 88, absent: 12 },
  ]

  const moduleDistribution = [
    { name: 'Akademik', value: 35, color: '#3b82f6' },
    { name: 'Keuangan', value: 25, color: '#10b981' },
    { name: 'Asrama', value: 20, color: '#8b5cf6' },
    { name: 'Administrasi', value: 15, color: '#f59e0b' },
    { name: 'Lainnya', value: 5, color: '#ef4444' },
  ]

  const recentActivities: RecentActivity[] = [
    { id: '1', type: 'Pembayaran', description: 'SPP bulan April 2026', user: 'Ahmad Santoso', time: '10 menit lalu', status: 'success' },
    { id: '2', type: 'Presensi', description: 'Presensi kelas 7A', user: 'Ustadz Budi', time: '30 menit lalu', status: 'success' },
    { id: '3', type: 'Pendaftaran', description: 'Santri baru diterima', user: 'Admin', time: '1 jam lalu', status: 'success' },
    { id: '4', type: 'Peringatan', description: 'Pembayaran terlambat', user: 'Sistem', time: '2 jam lalu', status: 'warning' },
    { id: '5', type: 'Laporan', description: 'Laporan bulanan keuangan', user: 'Bendahara', time: '3 jam lalu', status: 'success' },
  ]

  const topStudents = [
    { rank: 1, name: 'Ahmad Santoso', nis: '2026001', kelas: '7A', nilai: 98.5 },
    { rank: 2, name: 'Siti Rahma', nis: '2026002', kelas: '7B', nilai: 97.2 },
    { rank: 3, name: 'Muhammad Ali', nis: '2026003', kelas: '8A', nilai: 96.8 },
    { rank: 4, name: 'Fatimah Zahra', nis: '2026004', kelas: '8B', nilai: 95.5 },
    { rank: 5, name: 'Abdullah Rahman', nis: '2026005', kelas: '9A', nilai: 94.9 },
  ]

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-t-2 border-b-2 border-primary-500"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">Dashboard</h1>
          <p className="text-gray-600 dark:text-gray-400 mt-2">
            Selamat datang kembali! Berikut adalah ringkasan sistem pesantren Anda.
          </p>
        </div>
        <div className="flex items-center space-x-4">
          <Button variant="outline" className="flex items-center gap-2">
            <Download className="h-4 w-4" />
            Export Laporan
          </Button>
          <Button className="flex items-center gap-2">
            <Settings className="h-4 w-4" />
            Pengaturan
          </Button>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {quickStats.map((stat, index) => (
          <motion.div
            key={index}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
          >
            <Card>
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600 dark:text-gray-400">{stat.title}</p>
                    <h3 className="text-2xl font-bold mt-2">{stat.value}</h3>
                    <div className="flex items-center mt-2">
                      <TrendingUp className="h-4 w-4 text-green-500 mr-1" />
                      <span className="text-sm text-green-500">{stat.change}</span>
                      <span className="text-sm text-gray-500 ml-2">dari bulan lalu</span>
                    </div>
                  </div>
                  <div className={`${stat.color} p-3 rounded-full`}>
                    {stat.icon}
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        ))}
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Financial Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Statistik Keuangan</CardTitle>
            <CardDescription>Perkembangan pembayaran 6 bulan terakhir</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={financialData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="month" />
                  <YAxis />
                  <Tooltip formatter={(value) => [`Rp ${value.toLocaleString()}`, 'Jumlah']} />
                  <Legend />
                  <Line type="monotone" dataKey="paid" stroke="#10b981" strokeWidth={2} name="Sudah Dibayar" />
                  <Line type="monotone" dataKey="pending" stroke="#f59e0b" strokeWidth={2} name="Belum Dibayar" />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        {/* Attendance Chart */}
        <Card>
          <CardHeader>
            <CardTitle>Presensi Mingguan</CardTitle>
            <CardDescription>Persentase kehadiran santri</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={attendanceData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="day" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="present" fill="#3b82f6" name="Hadir (%)" />
                  <Bar dataKey="absent" fill="#ef4444" name="Tidak Hadir (%)" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Module Distribution & Recent Activities */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Module Distribution */}
        <Card className="lg:col-span-1">
          <CardHeader>
            <CardTitle>Distribusi Modul</CardTitle>
            <CardDescription>Penggunaan 40 modul sistem</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={moduleDistribution}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {moduleDistribution.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        {/* Recent Activities */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Aktivitas Terbaru</CardTitle>
            <CardDescription>Update terbaru dari sistem</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {recentActivities.map((activity) => (
                <div key={activity.id} className="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
                  <div className="flex items-center space-x-4">
                    <div className={`p-2 rounded-full ${
                      activity.status === 'success' ? 'bg-green-100 text-green-600' :
                      activity.status === 'warning' ? 'bg-yellow-100 text-yellow-600' :
                      'bg-red-100 text-red-600'
                    }`}>
                      {activity.status === 'success' ? <CheckCircle className="h-5 w-5" /> :
                       activity.status === 'warning' ? <AlertCircle className="h-5 w-5" /> :
                       <AlertCircle className="h-5 w-5" />}
                    </div>
                    <div>
                      <p className="font-medium">{activity.type}</p>
                      <p className="text-sm text-gray-600 dark:text-gray-400">{activity.description}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-medium">{activity.user}</p>
                    <p className="text-sm text-gray-500">{activity.time}</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Top Students & System Status */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top Students */}
        <Card>
          <CardHeader>
            <CardTitle>Top 5 Santri</CardTitle>
            <CardDescription>Santri dengan nilai tertinggi</CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Rank</TableHead>
                  <TableHead>Nama</TableHead>
                  <TableHead>NIS</TableHead>
                  <TableHead>Kelas</TableHead>
                  <TableHead className="text-right">Nilai</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {topStudents.map((student) => (
                  <TableRow key={student.rank}>
                    <TableCell>
                      <Badge variant={student.rank <= 3 ? "default" : "secondary"}>
                        #{student.rank}
                      </Badge>
                    </TableCell>
                    <TableCell className="font-medium">{student.name}</TableCell>
                    <TableCell>{student.nis}</TableCell>
                    <TableCell>{student.kelas}</TableCell>
                    <TableCell className="text-right font-bold">{student.nilai}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        {/* System Status */}
        <Card>
          <CardHeader>
            <CardTitle>Status Sistem</CardTitle>
            <CardDescription>Monitor kesehatan sistem</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium">API Server</span>
                  <Badge variant="success">Online</Badge>
                </div>
                <Progress value={100} className="h-2" />
              </div>
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium">Database</span>
                  <Badge variant="success">Connected</Badge>
                </div>
                <Progress value={95} className="h-2" />
              </div>
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium">Storage</span>
                  <Badge variant="warning">65% Used</Badge>
                </div>
                <Progress value={65} className="h-2" />
              </div>
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium">Backup</span>
                  <Badge variant="success">Up to date</Badge>
                </div>
                <Progress value={100} className="h-2" />
              </div>
            </div