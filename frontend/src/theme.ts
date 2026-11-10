import { createTheme } from '@mui/material/styles'

export const designTokens = {
  color: {
    background: '#f5f7fa',
    panel: '#ffffff',
    text: '#101828',
    border: '#d0d5dd',
    focus: '#155eef',
    warning: '#f79009',
    caution: '#f04438',
    note: '#175cd3'
  },
  spacing: {
    navWidth: 360
  }
}

export const appTheme = createTheme({
  palette: {
    mode: 'light',
    background: { default: designTokens.color.background, paper: designTokens.color.panel },
    text: { primary: designTokens.color.text },
    warning: { main: designTokens.color.warning },
    error: { main: designTokens.color.caution },
    info: { main: designTokens.color.note }
  },
  shape: {
    borderRadius: 8
  }
})
