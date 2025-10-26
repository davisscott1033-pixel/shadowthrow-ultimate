import * as React from 'react'

export type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: 'primary' | 'ghost'
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(function Button(
  { className, variant='primary', ...props }, ref
) {
  const base = 'inline-flex items-center justify-center rounded-xl px-4 py-2 text-sm font-medium transition-colors'
  const styles = variant === 'ghost'
    ? 'bg-transparent border border-gray-300 hover:bg-gray-50 dark:border-gray-700 dark:hover:bg-gray-900'
    : 'bg-indigo-600 text-white hover:bg-indigo-700'
  return <button ref={ref} className={[base, styles, className].filter(Boolean).join(' ')} {...props} />
})
