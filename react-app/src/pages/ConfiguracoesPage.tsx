import { Save } from 'lucide-react'
import { FormEvent, useEffect, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { PageHeader } from '../components/ui/PageHeader'
import { Card, CardBody, CardHeader } from '../components/ui/Card'
import { Button } from '../components/ui/Button'
import { ErrorState, LoadingState } from '../components/ui/States'
import { getConfiguracoes, updateConfiguracoes } from '../services/domain'
import { extractErrorMessage } from '../services/api'
import { asString } from '../utils/format'
import type { JsonRecord } from '../types/models'

export function ConfiguracoesPage({ clienteMode = false }: { clienteMode?: boolean }) {
  const client = useQueryClient()
  const query = useQuery({ queryKey: ['configuracoes', clienteMode], queryFn: getConfiguracoes, enabled: !clienteMode })
  const [form, setForm] = useState<JsonRecord>({})
  const mutation = useMutation({
    mutationFn: updateConfiguracoes,
    onSuccess: () => client.invalidateQueries({ queryKey: ['configuracoes'] }),
  })

  useEffect(() => {
    if (query.data) setForm(query.data)
  }, [query.data])

  if (clienteMode) {
    return (
      <div className="space-y-6">
        <PageHeader eyebrow="Cliente" accent="Configurações" title="da conta" subtitle="Dados do perfil e preferências do cliente parceiro." />
        <Card>
          <CardBody>
            {/* TODO(migration): conectar troca de senha e perfil aos endpoints /v1/auth/senha e /v1/cliente/perfil. */}
            <p className="text-sm text-ink-muted">Perfil do cliente parceiro.</p>
          </CardBody>
        </Card>
      </div>
    )
  }

  if (query.isLoading) return <LoadingState />
  if (query.isError) return <ErrorState message={extractErrorMessage(query.error)} onRetry={() => void query.refetch()} />

  function setField(key: string, value: string) {
    setForm((current) => ({ ...current, [key]: value }))
  }

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    mutation.mutate(form)
  }

  return (
    <div className="space-y-6">
      <PageHeader eyebrow="Administração" accent="Configurações" title="da unidade" subtitle="Campos principais da franquia e integrações expostos pelo backend." />

      <Card>
        <CardHeader>
          <p className="text-sm font-bold text-ink">Dados da unidade</p>
        </CardHeader>
        <CardBody>
          <form className="grid gap-4 md:grid-cols-2" onSubmit={onSubmit}>
            {['nome_franquia', 'cnpj', 'email', 'telefone', 'cidade', 'estado'].map((key) => (
              <label key={key} className="block">
                <span className="text-sm font-semibold capitalize text-ink">{key.replace(/_/g, ' ')}</span>
                <input
                  className="mt-2 h-11 w-full rounded-lg border border-line bg-surface-muted px-4 outline-none focus:border-brand focus:ring-4 focus:ring-brand/10"
                  value={asString(form[key], '')}
                  onChange={(event) => setField(key, event.target.value)}
                />
              </label>
            ))}
            {mutation.isError ? <p className="md:col-span-2 rounded-lg bg-red-50 px-4 py-3 text-sm font-medium text-red-700">{extractErrorMessage(mutation.error)}</p> : null}
            {mutation.isSuccess ? <p className="md:col-span-2 rounded-lg bg-emerald-50 px-4 py-3 text-sm font-medium text-emerald-700">Configurações salvas.</p> : null}
            <div className="md:col-span-2">
              <Button type="submit" icon={Save} isLoading={mutation.isPending}>
                Salvar
              </Button>
            </div>
          </form>
        </CardBody>
      </Card>
    </div>
  )
}
