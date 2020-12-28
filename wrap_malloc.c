#include <errno.h>
#include <rtthread.h>
#include <stddef.h>
#include <reent.h>

void *__wrap__malloc_r(struct _reent *r, size_t size)
{
    void *res = rt_malloc(size);
    if (size && !res)
        r->_errno = ENOMEM;
    return res;
}

void * __wrap__realloc_r(struct _reent *r, void *ptr, size_t size)
{
    void *res = rt_realloc(ptr, size);
    if (ptr && size && !res)
        r->_errno = ENOMEM;
    return res;
}

void *__wrap__calloc_r(struct _reent *r, size_t n, size_t size)
{
    return __wrap__malloc_r(r, n * size);
}

void __wrap__free_r(struct _reent *r, void *ptr)
{
    rt_free(ptr);
}
