import { clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: any[]) {
  return twMerge(clsx(inputs))
}

type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & { variant?: 'default'|'ghost' }
export function Button({ className, variant='default', ...props }: ButtonProps) {
  const base = 'inline-flex items-center justify-center rounded-xl px-4 py-2 text-sm font-medium transition-colors';
  const styles = variant === 'ghost' 
    ? 'bg-transparent hover:bg-gray-100 dark:hover:bg-gray-900 border border-transparent'
    : 'bg-indigo-600 text-white hover:bg-indigo-700';
  return <button className={cn(base, styles, className)} {...props} />
}
