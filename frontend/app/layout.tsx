import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Providers } from './providers'
import { Toaster } from 'react-hot-toast'
import { Navigation } from '@/components/layout/Navigation'
import { Sidebar } from '@/components/layout/Sidebar'
import { Footer } from '@/components/layout/Footer'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Sistem Informasi Pesantren - Admin Panel',
  description: 'Sistem manajemen terintegrasi untuk pondok pesantren dengan 40 modul lengkap',
  keywords: ['pesantren', 'education', 'management', 'islamic', 'school', 'admin'],
  authors: [{ name: 'Pesantren System Team' }],
  creator: 'Pesantren System',
  publisher: 'Pesantren System',
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  openGraph: {
    type: 'website',
    locale: 'id_ID',
    url: 'https://pesantren.example.com',
    title: 'Sistem Informasi Pesantren',
    description: 'Sistem manajemen terintegrasi untuk pondok pesantren',
    siteName: 'Pesantren System',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'Pesantren System Admin Panel',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Sistem Informasi Pesantren',
    description: 'Sistem manajemen terintegrasi untuk pondok pesantren',
    images: ['/og-image.png'],
    creator: '@pesantren_system',
  },
  viewport: {
    width: 'device-width',
    initialScale: 1,
    maximumScale: 1,
  },
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#ffffff' },
    { media: '(prefers-color-scheme: dark)', color: '#111827' },
  ],
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="id" suppressHydrationWarning>
      <body className={`${inter.className} bg-gray-50 dark:bg-gray-900`}>
        <Providers>
          <div className="min-h-screen flex flex-col">
            <Navigation />
            <div className="flex flex-1">
              <Sidebar />
              <main className="flex-1 p-6 overflow-auto">
                <div className="max-w-7xl mx-auto">
                  {children}
                </div>
              </main>
            </div>
            <Footer />
          </div>
          <Toaster 
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: '#363636',
                color: '#fff',
              },
              success: {
                duration: 3000,
                iconTheme: {
                  primary: '#10b981',
                  secondary: '#fff',
                },
              },
              error: {
                duration: 5000,
                iconTheme: {
                  primary: '#ef4444',
                  secondary: '#fff',
                },
              },
            }}
          />
        </Providers>
      </body>
    </html>
  )
}