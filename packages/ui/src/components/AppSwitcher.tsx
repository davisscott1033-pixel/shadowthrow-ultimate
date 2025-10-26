'use client'

import * as React from 'react'

type Props = {
  webUrl?: string
  importedUrl?: string
}

export function AppSwitcher({ webUrl='http://localhost:3000', importedUrl='http://localhost:3001' }: Props) {
  return (
    <div className="inline-flex items-center gap-2 rounded-xl border border-gray-300 dark:border-gray-700 p-1">
      <a className="px-3 py-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-900" href={webUrl}>Web</a>
      <a className="px-3 py-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-900" href={importedUrl}>Imported</a>
    </div>
  )
}
