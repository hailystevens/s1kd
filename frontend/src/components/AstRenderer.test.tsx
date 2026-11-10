import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { AstRenderer } from './AstRenderer'

const paragraphNode = {
  type: 'document' as const,
  name: 'dmodule',
  attributes: {},
  xpath: '/',
  children: [
    {
      type: 'element' as const,
      name: 'para',
      attributes: {},
      xpath: '/dmodule/para[1]',
      children: [
        {
          type: 'text' as const,
          name: '#text',
          text: 'Rendered text',
          attributes: {},
          xpath: '/dmodule/para[1]/text()[1]',
          children: []
        }
      ]
    }
  ]
}

describe('AstRenderer', () => {
  it('renders paragraph text from AST nodes', () => {
    render(<AstRenderer node={paragraphNode} />)
    expect(screen.getByText('Rendered text')).toBeInTheDocument()
  })

  it('renders cross-reference links and anchor ids', () => {
    const crossRefNode = {
      type: 'document' as const,
      name: 'dmodule',
      attributes: {},
      xpath: '/',
      children: [
        {
          type: 'element' as const,
          name: 'brPara',
          attributes: { id: 'TARGET-1' },
          xpath: '/dmodule/brPara[1]',
          children: [
            {
              type: 'element' as const,
              name: 'para',
              attributes: {},
              xpath: '/dmodule/brPara[1]/para[1]',
              children: [
                {
                  type: 'text' as const,
                  name: '#text',
                  text: 'Target content',
                  attributes: {},
                  xpath: '/dmodule/brPara[1]/para[1]/text()[1]',
                  children: []
                }
              ]
            }
          ]
        },
        {
          type: 'element' as const,
          name: 'internalRef',
          attributes: { internalRefId: 'TARGET-1' },
          xpath: '/dmodule/internalRef[1]',
          children: [
            {
              type: 'text' as const,
              name: '#text',
              text: 'Jump to target',
              attributes: {},
              xpath: '/dmodule/internalRef[1]/text()[1]',
              children: []
            }
          ]
        }
      ]
    }

    const { container } = render(<AstRenderer node={crossRefNode} />)
    expect(screen.getByRole('link', { name: 'Jump to target' })).toHaveAttribute('href', '#TARGET-1')
    expect(container.querySelector('#TARGET-1')).toBeInTheDocument()
  })
})
