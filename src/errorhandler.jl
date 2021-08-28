"""
    MPI.ErrorHandler

An MPI error handler object. Currently only two are supported:

- `ERRORS_ARE_FATAL` (default): program will immediately abort
- `ERRORS_RETURN`: program will throw an `MPIError`.
"""
@mpi_handle ErrorHandler MPI_Errhandler

const ERRORS_ARE_FATAL = _ErrorHandler(MPI_ERRORS_ARE_FATAL)
const ERRORS_RETURN = _ErrorHandler(MPI_ERRORS_RETURN)

function free(errh::ErrorHandler)
    if !Finalized()
        # int MPI_Errhandler_free(MPI_Errhandler *errhandler)
        @mpichk ccall((:MPI_Errhandler_free, libmpi), Cint, (Ptr{MPI_Errhandler},), errh)
    end
    return nothing
end

function set_default_errhandler_return()
    set_errhandler!(COMM_SELF, ERRORS_RETURN)
    set_errhandler!(COMM_WORLD, ERRORS_RETURN)
end

"""
    MPI.get_errhandler(comm::MPI.Comm)
    MPI.get_errhandler(win::MPI.Win)
    MPI.get_errhandler(file::MPI.File.FileHandle)

Get the current [`ErrorHandler`](@ref) for the relevant MPI object.

# See also
- [`set_errhandler!`](@ref)
"""
function get_errhandler(comm::Comm)
    errh = ErrorHandler(ERRORS_ARE_FATAL.val)
    @mpichk ccall((:MPI_Comm_get_errhandler, libmpi), Cint, (MPI_Comm, Ptr{MPI_Errhandler}), comm, errh)
    finalizer(free, errh)
    return errh
end
function get_errhandler(win::Win)
    errh = v(ERRORS_ARE_FATAL.val)
    @mpichk ccall((:MPI_Win_get_errhandler, libmpi), Cint, (MPI_Win, Ptr{MPI_Errhandler}), win, errh)
    return errh
end
function get_errhandler(file::File.FileHandle)
    errh = ErrorHandler(ERRORS_ARE_FATAL.val)
    @mpichk ccall((:MPI_File_get_errhandler, libmpi), Cint, (MPI_File, Ptr{MPI_Errhandler}), file, errh)
    return errh
end

"""
    MPI.set_errhandler!(comm::MPI.Comm, errh::Errhandler)
    MPI.set_errhandler!(win::MPI.Win, errh::Errhandler)
    MPI.set_errhandler!(file::MPI.File.FileHandle, errh::Errhandler)

Set the [`ErrorHandler`](@ref) for the relevant MPI object.

# See also
- [`get_errhandler`](@ref)
"""
function set_errhandler!(comm::Comm, errh::ErrorHandler)
    @mpichk ccall((:MPI_Comm_set_errhandler, libmpi), Cint, (MPI_Comm, MPI_Errhandler), comm, errh)
    return nothing
end
function set_errhandler!(win::Win, errh::ErrorHandler)
    @mpichk ccall((:MPI_Win_set_errhandler, libmpi), Cint, (MPI_Win, MPI_Errhandler), win, errh)
    return nothing
end
function set_errhandler!(file::File.FileHandle, errh::ErrorHandler)
    @mpichk ccall((:MPI_File_set_errhandler, libmpi), Cint, (MPI_File, MPI_Errhandler), file, errh)
    return nothing
end


